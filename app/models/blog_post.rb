class BlogPost < ApplicationRecord
  enum :status, { draft: 0, published: 1 }

  has_rich_text :body

  before_validation :set_slug
  before_validation :set_published_at

  validates :title, :slug, :excerpt, :body, presence: true
  validates :slug, uniqueness: true

  scope :recent, -> { published.order(published_at: :desc, created_at: :desc) }

  def to_param
    slug
  end

  private

  def set_slug
    self.slug = title.to_s.parameterize if slug.blank? && title.present?
  end

  def set_published_at
    self.published_at = Time.current if published? && published_at.blank?
  end
end
