require "test_helper"

class BlogPostsControllerTest < ActionDispatch::IntegrationTest
  test "lists only published posts" do
    get blog_posts_path

    assert_response :success
    assert_match blog_posts(:published_post).title, response.body
    assert_no_match blog_posts(:draft_post).title, response.body
  end

  test "show page displays meta keywords when present" do
    post = blog_posts(:published_post)
    get blog_post_path(post)

    assert_response :success
    assert_select "meta[name='keywords'][content='scrum, ai, blog']"
  end
end
