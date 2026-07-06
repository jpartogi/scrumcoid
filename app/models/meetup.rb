class Meetup < ApplicationRecord
  include PageViewable

  DEFAULT_NAME = "Scrum Meetup"
  DEFAULT_TIMEZONE = "Asia/Jakarta"
  SLUG_PATTERN = /\A[a-z0-9]+(?:-[a-z0-9]+)*-\d{4}-\d{2}-\d{2}(?:-\d+)?\z/

  enum :status, { draft: 0, published: 1, cancelled: 2 }

  has_many :meetup_registrations, dependent: :destroy
  has_rich_text :description

  before_validation :set_default_name
  before_validation :set_default_timezone
  before_validation :assign_slug

  validates :name, :excerpt, :description, :slug, :starts_at, :ends_at,
            :registration_deadline, :timezone, presence: true
  validates :slug, uniqueness: true, format: { with: SLUG_PATTERN }
  validates :capacity, numericality: { greater_than: 0 }
  validate :timezone_must_be_valid
  validate :ends_after_start
  validate :single_day_event

  scope :upcoming, -> { where("starts_at >= ?", Time.current).order(:starts_at) }
  scope :past, -> { where("starts_at < ?", Time.current).order(starts_at: :desc) }
  scope :available, -> { published.upcoming.where("registration_deadline >= ?", Time.current) }

  def to_param
    slug
  end

  def display_name
    "#{name} · #{event_date.strftime('%Y-%m-%d')}"
  end

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
    meetup_registrations.active.count
  end

  def remaining_seats
    capacity - registration_count
  end

  def time_zone
    ActiveSupport::TimeZone[timezone]
  end

  def event_date
    starts_at.in_time_zone(time_zone || Time.zone).to_date
  end

  def donation_url
    paypal_donation_url.presence || ENV["PAYPAL_DONATION_URL"].presence
  end

  def ended?
    ends_at.past?
  end

  private

  def assign_slug
    return if starts_at.blank? || time_zone.blank? || name.blank?
    return if persisted? && !starts_at_changed? && !timezone_changed? && !name_changed?

    slug_prefix = "#{name.parameterize}-#{event_date.strftime('%Y-%m-%d')}"
    scope = self.class.where("slug = ? OR slug LIKE ?", slug_prefix, "#{slug_prefix}-%")
    scope = scope.where.not(id: id) if persisted?

    if scope.empty?
      self.slug = slug_prefix
    else
      used_suffixes = scope.pluck(:slug).filter_map do |existing_slug|
        next 1 if existing_slug == slug_prefix

        suffix = existing_slug.delete_prefix("#{slug_prefix}-")
        suffix.to_i if suffix.match?(/\A\d+\z/)
      end

      self.slug = "#{slug_prefix}-#{used_suffixes.max.to_i + 1}"
    end
  end

  def set_default_name
    self.name = DEFAULT_NAME if name.blank?
  end

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

  def single_day_event
    return if starts_at.blank? || ends_at.blank? || time_zone.blank?

    start_date = starts_at.in_time_zone(time_zone).to_date
    end_date = ends_at.in_time_zone(time_zone).to_date
    return if start_date == end_date

    errors.add(:ends_at, "must be on the same day as the start time")
  end
end