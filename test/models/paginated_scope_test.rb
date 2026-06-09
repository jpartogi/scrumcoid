require "test_helper"

class PaginatedScopeTest < ActiveSupport::TestCase
  setup do
    @original_per_page = PaginatedScope.default_per_page
    PaginatedScope.default_per_page = 2
  end

  teardown do
    PaginatedScope.default_per_page = @original_per_page
  end

  test "wraps scope with page limits" do
    first_page = PaginatedScope.wrap(BlogPost.order(:id), page: 1)
    second_page = PaginatedScope.wrap(BlogPost.order(:id), page: 2)

    assert_equal 2, first_page.records.size
    assert_equal 1, second_page.records.size
    assert_equal BlogPost.count, first_page.total_count
  end

  test "clamps invalid page numbers" do
    paginated = PaginatedScope.wrap(BlogPost.order(:id), page: 99)

    assert_equal 2, paginated.current_page
  end

  test "normalize_per_page clamps values to allowed range" do
    assert_equal PaginatedScope.default_per_page, PaginatedScope.normalize_per_page(nil)
    assert_equal PaginatedScope.default_per_page, PaginatedScope.normalize_per_page(0)
    assert_equal 5, PaginatedScope.normalize_per_page(5)
    assert_equal 100, PaginatedScope.normalize_per_page(500)
  end
end