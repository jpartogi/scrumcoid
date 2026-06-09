require "test_helper"

class Admin::BlogPostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:admin)
    @original_per_page = PaginatedScope.default_per_page
    PaginatedScope.default_per_page = 2
  end

  teardown do
    PaginatedScope.default_per_page = @original_per_page
  end

  test "index lists blog posts with sortable headers" do
    get admin_blog_posts_path

    assert_response :success
    # Title and Published sort links render as <a> tags with sort params
    assert_select "a[href*='sort=title']", text: /Title/
    assert_select "a[href*='sort=published_at']", text: /Published/
    assert_select "tbody tr", minimum: 1
  end

  test "index sorts by title ascending" do
    get admin_blog_posts_path(sort: "title", direction: "asc")

    assert_response :success
    # Active sort header gets the indigo highlight class
    assert_select "a[href*='sort=title'][href*='direction=desc']"
  end

  test "index sorts by published_at descending" do
    get admin_blog_posts_path(sort: "published_at", direction: "desc")

    assert_response :success
    assert_select "a[href*='sort=published_at'][href*='direction=asc']"
  end

  test "index defaults to ten posts per page" do
    get admin_blog_posts_path

    assert_response :success
    assert_select "input[name='per_page'][value='10']"
  end

  test "index paginates blog posts" do
    get admin_blog_posts_path(per_page: 2)

    assert_response :success
    assert_select "nav[aria-label='Pagination']"
    assert_select "tbody tr", count: 2

    get admin_blog_posts_path(page: 2, per_page: 2)

    assert_response :success
    assert_select "tbody tr", count: 1
  end

  test "index respects per_page parameter" do
    get admin_blog_posts_path(per_page: 1)

    assert_response :success
    assert_select "tbody tr", count: 1
    assert_select "input[name='per_page'][value='1']"
    assert_select "nav[aria-label='Pagination']"
  end
end