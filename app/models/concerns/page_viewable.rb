module PageViewable
  extend ActiveSupport::Concern

  included do
    has_many :page_views, as: :viewable, dependent: :destroy
  end

  def page_view_stats
    @page_view_stats ||= PageViewStats.new(self)
  end
end