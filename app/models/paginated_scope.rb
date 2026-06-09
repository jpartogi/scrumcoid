class PaginatedScope
  include Enumerable

  MIN_PER_PAGE = 1
  MAX_PER_PAGE = 100

  class << self
    attr_accessor :default_per_page
  end

  self.default_per_page = 20

  delegate :any?, :empty?, :size, :count, to: :records

  attr_reader :records, :current_page, :per_page, :total_count, :total_pages

  def self.normalize_per_page(value)
    per_page = value.to_i
    per_page = default_per_page if per_page < MIN_PER_PAGE

    [per_page, MAX_PER_PAGE].min
  end

  def self.wrap(scope, page:, per_page: default_per_page)
    new(scope, page:, per_page: normalize_per_page(per_page))
  end

  def initialize(scope, page:, per_page: self.class.default_per_page)
    @per_page = self.class.normalize_per_page(per_page)
    @total_count = scope.count
    @total_pages = @total_count.zero? ? 0 : (@total_count.to_f / per_page).ceil
    @current_page = page.to_i
    @current_page = 1 if @current_page < 1
    @current_page = @total_pages if @total_pages.positive? && @current_page > @total_pages
    @records = scope.offset((@current_page - 1) * per_page).limit(per_page)
  end

  def each(&block)
    records.each(&block)
  end

  def first_page?
    current_page == 1
  end

  def last_page?
    total_pages.zero? || current_page == total_pages
  end
end