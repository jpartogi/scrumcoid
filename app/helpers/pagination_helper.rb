module PaginationHelper
  def paginated_path(path_helper, paginated, page:)
    path_helper.call(page: page, per_page: paginated.per_page)
  end

  def page_entries_info_for(paginated, entry_name: "entry")
    return "" if paginated.total_count.zero?

    first = ((paginated.current_page - 1) * paginated.per_page) + 1
    last = [paginated.current_page * paginated.per_page, paginated.total_count].min
    noun = entry_name.pluralize(paginated.total_count)

    "Showing #{first}–#{last} of #{paginated.total_count} #{noun}"
  end

  def pagination_window(paginated, radius: 2)
    return [] if paginated.total_pages <= 1

    pages = Set.new([1, paginated.total_pages])
    ((paginated.current_page - radius)..(paginated.current_page + radius)).each do |page|
      pages << page if page.between?(1, paginated.total_pages)
    end

    pages.sort
  end
end