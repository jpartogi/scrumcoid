class ClassSchedule < ApplicationRecord
  include PageViewable

  DEFAULT_TIMEZONE = "Asia/Jakarta"

  enum :status, { unpublished: 0, published: 1, cancelled: 2 }

  belongs_to :course
  belongs_to :venue, optional: true

  # Delegate so existing views using class_schedule.venue_name / .venue_address keep working
  delegate :name, :address, to: :venue, prefix: true, allow_nil: true

  def start_date
    starts_at.in_time_zone(time_zone).to_date
  end

  def end_date
    ends_at.in_time_zone(time_zone).to_date
  end

  has_many :enrollments, dependent: :destroy
  has_many :students, through: :enrollments, source: :user

  before_validation :set_default_timezone

  validates :starts_at, :ends_at, :location, :registration_deadline, :timezone, presence: true
  validates :capacity, numericality: { greater_than: 0 }
  validates :venue, presence: true, unless: :online?
  validate :timezone_must_be_valid
  validate :ends_after_start

  scope :upcoming, -> { where("starts_at >= ?", Time.current).order(:starts_at) }
  scope :available, -> { published.upcoming.where("registration_deadline >= ?", Time.current) }

  def available_for_registration?
    published? && registration_deadline.future? && starts_at.future? && remaining_seats.positive?
  end

  def full?
    remaining_seats <= 0
  end

  def registration_closed?
    registration_deadline.past? || starts_at.past? || !published?
  end

  def registration_count
    enrollments.active.count
  end

  def remaining_seats
    capacity - registration_count
  end

  def price_for(currency)
    course&.price_for(currency)
  end

  def display_price_for(currency)
    course&.display_price_for(currency) || "Price unavailable"
  end

  def time_zone
    ActiveSupport::TimeZone[timezone]
  end

  private

  def set_default_timezone
    self.timezone = DEFAULT_TIMEZONE if timezone.blank?
  end

  def timezone_must_be_valid
    return if timezone.blank? || time_zone.present?

    errors.add(:timezone, "must be a valid time zone")
  end

  def ends_after_start
    return if starts_at.blank? || ends_at.blank?

    errors.add(:ends_at, "must be after the start time") unless ends_at > starts_at
  end
end
