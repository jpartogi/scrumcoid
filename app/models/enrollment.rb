class Enrollment < ApplicationRecord
  enum :status, { active: 0, cancelled: 1 }

  attribute :first_name, :string
  attribute :last_name, :string
  attribute :email, :string
  attribute :country, :string

  belongs_to :user, optional: true
  belongs_to :class_schedule
  belongs_to :registration, optional: true

  attr_accessor :skip_registration_limits

  before_validation :copy_company_details_from_registration
  before_create :generate_invitation_token

  validates :user_id, uniqueness: { scope: :class_schedule_id }, allow_nil: true
  validates :first_name, :last_name, :email, presence: true, if: -> { user.blank? }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validate :class_schedule_accepts_registration, on: :create

  delegate :course, to: :class_schedule

  scope :matching_student_query, ->(query) {
    term = query.to_s.strip
    next all if term.blank?

    pattern = "%#{sanitize_sql_like(term)}%"
    left_joins(:user, registration: :customer).where(student_search_sql, q: pattern)
  }

  def self.student_search_sql
    student_search_clauses.join(" OR ")
  end

  def self.student_search_clauses
    op = like_operator
    [
      "enrollments.first_name #{op} :q",
      "enrollments.last_name #{op} :q",
      "enrollments.email #{op} :q",
      "enrollments.company_name #{op} :q",
      "registrations.company_name #{op} :q",
      "customers.company_name #{op} :q",
      "users.name #{op} :q",
      "users.email #{op} :q",
      "#{user_first_name_sql} #{op} :q",
      "#{user_last_name_sql} #{op} :q"
    ]
  end

  def self.like_operator
    connection.adapter_name.match?(/PostgreSQL/i) ? "ILIKE" : "LIKE"
  end

  def self.user_first_name_sql
    if connection.adapter_name.match?(/PostgreSQL/i)
      "split_part(users.name, ' ', 1)"
    else
      "CASE WHEN instr(users.name, ' ') > 0 THEN substr(users.name, 1, instr(users.name, ' ') - 1) ELSE users.name END"
    end
  end

  def self.user_last_name_sql
    if connection.adapter_name.match?(/PostgreSQL/i)
      "NULLIF(split_part(users.name, ' ', 2), '')"
    else
      "CASE WHEN instr(users.name, ' ') > 0 THEN substr(users.name, instr(users.name, ' ') + 1) ELSE '' END"
    end
  end

  private_class_method :student_search_clauses, :like_operator, :user_first_name_sql, :user_last_name_sql

  def attendee_name
    user&.name.presence || full_name
  end

  def attendee_email
    user&.email.presence || email
  end

  def full_name
    [first_name, last_name].compact_blank.join(" ")
  end

  def course_history
    scope = Enrollment.includes(class_schedule: :course).order(created_at: :desc)

    if user_id.present?
      scope.where(user_id: user_id)
    else
      normalized_email = attendee_email.to_s.strip.downcase
      return Enrollment.none if normalized_email.blank?

      scope.left_joins(:user).where(
        "LOWER(enrollments.email) = :email OR LOWER(users.email) = :email",
        email: normalized_email
      )
    end
  end

  private

  def copy_company_details_from_registration
    if registration.present?
      self.company_name ||= registration.company_name
      self.company_address ||= registration.company_address
      self.company_phone ||= registration.company_phone
      self.finance_name ||= registration.finance_name
      self.finance_email ||= registration.finance_email
    end
  end

  def generate_invitation_token
    self.invitation_token ||= SecureRandom.hex(16)
  end

  def class_schedule_accepts_registration
    return if skip_registration_limits
    return if class_schedule.blank?

    if class_schedule.full?
      errors.add(:class_schedule, "is full")
    elsif class_schedule.registration_closed?
      errors.add(:class_schedule, "is closed for registration")
    end
  end
end