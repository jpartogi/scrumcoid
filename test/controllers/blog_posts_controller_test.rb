require "test_helper"

class BlogPostsControllerTest < ActionDispatch::IntegrationTest
  test "lists only published posts" do
    get blog_posts_path

    assert_response :success
    assert_match blog_posts(:published_post).title, response.body
    assert_no_match blog_posts(:draft_post).title, response.body
  end
end
