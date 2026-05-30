class ClassSchedule < ApplicationRecord
  DEFAULT_TIMEZONE = "Australia/Brisbane"

  enum :status, { unpublished: 0, published: 1, cancelled: 2 }

  belongs_to :course
  has_many :enrollments, dependent: :destroy
  has_many :class_schedule_prices, dependent: :destroy
  has_many :students, through: :enrollments, source: :user

  accepts_nested_attributes_for :class_schedule_prices, allow_destroy: true, reject_if: :all_blank

  before_validation :set_default_timezone

  validates :starts_at, :ends_at, :location, :registration_deadline, :timezone, presence: true
  validates :capacity, numericality: { greater_than: 0 }
  validate :timezone_must_be_valid
  validate :ends_after_start
  validate :at_least_one_price

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
    preferred_currency = currency.to_s.upcase
    class_schedule_prices.find { |price| price.currency == preferred_currency } ||
      class_schedule_prices.find { |price| price.currency == CurrencyResolver::DEFAULT_CURRENCY } ||
      class_schedule_prices.first
  end

  def display_price_for(currency)
    price_for(currency)&.display_amount || "Price unavailable"
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

  def at_least_one_price
    return if class_schedule_prices.reject(&:marked_for_destruction?).any?

    errors.add(:class_schedule_prices, "must include at least one price")
  end

  def ends_after_start
    return if starts_at.blank? || ends_at.blank?

    errors.add(:ends_at, "must be after the start time") unless ends_at > starts_at
  end
end
