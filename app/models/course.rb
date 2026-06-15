class Course < ApplicationRecord
  enum :status, { draft: 0, published: 1 }

  has_many :course_prices, dependent: :destroy
  has_many :class_schedules, dependent: :destroy
  has_rich_text :description
  has_rich_text :invitation_email
  has_one_attached :logo
  has_one_attached :thumbnail

  accepts_nested_attributes_for :course_prices, allow_destroy: true, reject_if: :all_blank

  before_validation :set_slug

  validates :title, :excerpt, :description, :slug, presence: true
  validate :logo_must_be_an_image
  validate :thumbnail_must_be_an_image
  validates :slug, uniqueness: true

  scope :featured, -> { published.joins(:class_schedules).merge(ClassSchedule.available).distinct.limit(3) }

  def price_for(currency)
    preferred_currency = currency.to_s.upcase
    course_prices.find { |price| price.currency == preferred_currency } ||
      course_prices.find { |price| price.currency == CurrencyResolver::DEFAULT_CURRENCY } ||
      course_prices.first
  end

  def display_price_for(currency)
    price_for(currency)&.display_amount || "Price unavailable"
  end

  def active_enrollment_count
    Enrollment.active.joins(:class_schedule).where(class_schedules: { course_id: id }).count
  end

  def to_param
    slug
  end

  def tag_list
    tags.to_s.split(",").map(&:strip).reject(&:blank?)
  end

  def related_blog_posts(limit: 3)
    return BlogPost.none if tag_list.empty?

    scope = BlogPost.recent
    tag_list.reduce(BlogPost.none) do |result, tag|
      result.or(scope.with_tag(tag))
    end.distinct.limit(limit)
  end

  private

  def set_slug
    self.slug = title.to_s.parameterize if slug.blank? && title.present?
  end

  def logo_must_be_an_image
    return unless logo.attached?
    return if logo.content_type.in?(%w[image/png image/jpeg image/webp image/svg+xml])

    errors.add(:logo, "must be a PNG, JPG, WebP, or SVG image")
  end

  def thumbnail_must_be_an_image
    return unless thumbnail.attached?
    return if thumbnail.content_type.in?(%w[image/png image/jpeg image/webp image/svg+xml])

    errors.add(:thumbnail, "must be a PNG, JPG, WebP, or SVG image")
  end
end
