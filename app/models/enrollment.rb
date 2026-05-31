class Enrollment < ApplicationRecord
  enum :status, { active: 0, cancelled: 1 }

  belongs_to :user, optional: true
  belongs_to :class_schedule
  belongs_to :registration, optional: true

  validates :user_id, uniqueness: { scope: :class_schedule_id }, allow_nil: true
  validates :visitor_email, presence: true, if: -> { user.blank? }
  validates :visitor_email, uniqueness: { scope: :class_schedule_id }, allow_blank: true
  validate :class_schedule_accepts_registration, on: :create

  delegate :course, to: :class_schedule

  def attendee_name
    user&.name.presence || visitor_name
  end

  def attendee_email
    user&.email.presence || visitor_email
  end

  private

  def class_schedule_accepts_registration
    return if class_schedule.blank?

    if class_schedule.full?
      errors.add(:class_schedule, "is full")
    elsif class_schedule.registration_closed?
      errors.add(:class_schedule, "is closed for registration")
    end
  end
end
