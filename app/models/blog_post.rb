class BlogPost < ApplicationRecord
  include PageViewable

  enum :status, { draft: 0, published: 1 }

  has_rich_text :body

  before_validation :set_slug
  before_validation :set_published_at

  validates :title, :slug, :excerpt, :body, presence: true
  validates :slug, uniqueness: true

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

  def related_by_tags(limit: 3)
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
end
