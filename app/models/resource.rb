class Resource < ApplicationRecord
  include PageViewable

  DEFAULT_CURRENCY = "IDR"

  enum :status, { draft: 0, published: 1 }

  has_rich_text :description
  has_one_attached :thumbnail
  has_one_attached :file_attachment
  has_many :resource_download_requests, dependent: :destroy

  before_validation :set_slug
  before_validation :set_published_at
  before_validation :normalize_currency

  validates :title, :slug, :description, presence: true
  validates :slug, uniqueness: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, presence: true, length: { is: 3 }
  validates :page_count, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validate :thumbnail_must_be_an_image, on: :admin_save
  validate :file_attachment_must_be_allowed_type, on: :admin_save

  scope :recent, -> { published.order(published_at: :desc, created_at: :desc) }
  scope :with_tag, ->(tag_name) {
    normalized = normalize_tag(tag_name)
    next none if normalized.blank?

    pattern = "%,#{normalized.gsub(/\s+/, "")},%"
    where("LOWER(REPLACE(',' || COALESCE(tags, '') || ',', ' ', '')) LIKE ?", pattern)
  }

  def to_param
    slug
  end

  def tag_list
    tags.to_s.split(",").map(&:strip).reject(&:blank?)
  end

  def paid?
    price.to_f.positive?
  end

  def free?
    !paid?
  end

  def available_for_email_download?
    published? && free? && file_attachment.attached?
  end

  def display_price
    curr = currency.to_s.upcase
    if curr == DEFAULT_CURRENCY
      formatted = ActiveSupport::NumberHelper.number_to_delimited(price.to_i, delimiter: ".")
      "#{curr} #{formatted},-"
    else
      num = price.to_f
      formatted = num == num.floor ? ActiveSupport::NumberHelper.number_to_delimited(num.to_i) : ActiveSupport::NumberHelper.number_to_delimited(format("%.2f", num))
      "#{curr} #{formatted}"
    end
  end

  def related_resources(limit: 3)
    return self.class.none if tag_list.empty?

    scope = self.class.recent.where.not(id: id)
    tag_list.reduce(self.class.none) do |result, tag|
      result.or(scope.with_tag(tag))
    end.distinct.limit(limit)
  end

  def self.normalize_tag(tag)
    tag.to_s.strip.downcase
  end

  def self.all_tags
    recent
      .where.not(tags: [nil, ""])
      .pluck(:tags)
      .flat_map { |tags| tags.split(",").map(&:strip) }
      .reject(&:blank?)
      .uniq { |tag| normalize_tag(tag) }
      .sort_by { |tag| normalize_tag(tag) }
  end

  private

  def set_slug
    self.slug = title.to_s.parameterize if slug.blank? && title.present?
  end

  def set_published_at
    self.published_at = Time.current if published? && published_at.blank?
  end

  def normalize_currency
    self.currency = currency.to_s.upcase.strip.presence || DEFAULT_CURRENCY
  end

  def thumbnail_must_be_an_image
    return unless thumbnail.attached?
    return if thumbnail.content_type.in?(%w[image/png image/jpeg image/webp image/svg+xml])

    errors.add(:thumbnail, "must be a PNG, JPG, WebP, or SVG image")
  end

  def file_attachment_must_be_allowed_type
    return unless file_attachment.attached?

    allowed = %w[
      application/pdf
      application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
      application/vnd.ms-excel
    ]
    return if file_attachment.content_type.in?(allowed)

    errors.add(:file_attachment, "must be a PDF or Excel file")
  end
end