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

  validates :user_id, uniqueness: { scope: :class_schedule_id }, allow_nil: true
  validates :first_name, :last_name, :email, presence: true, if: -> { user.blank? }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validate :class_schedule_accepts_registration, on: :create

  delegate :course, to: :class_schedule

  def attendee_name
    user&.name.presence || full_name
  end

  def attendee_email
    user&.email.presence || email
  end

  def full_name
    [first_name, last_name].compact_blank.join(" ")
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