require "test_helper"

class BlogPostsControllerTest < ActionDispatch::IntegrationTest
  test "lists only published posts" do
    get blog_posts_path

    assert_response :success
    assert_match blog_posts(:published_post).title, response.body
    assert_no_match blog_posts(:draft_post).title, response.body
  end

  test "index displays all clickable tags at the top" do
    get blog_posts_path

    assert_response :success
    assert_select "a[href=?]", blog_posts_path(tag: "scrum"), text: /scrum/
    assert_select "a[href=?]", blog_posts_path(tag: "ai"), text: /ai/
    assert_select "a[href=?]", blog_posts_path(tag: "agile"), text: /agile/
    assert_select "a[href=?]", blog_posts_path, text: /Semua/
  end

  test "show page displays meta keywords when present" do
    post = blog_posts(:published_post)
    get blog_post_path(post)

    assert_response :success
    assert_select "meta[name='keywords'][content='scrum, ai, blog']"
  end

  test "index filters posts by tag" do
    get blog_posts_path(tag: "scrum")

    assert_response :success
    assert_match blog_posts(:published_post).title, response.body
    assert_match blog_posts(:related_post).title, response.body
    assert_no_match blog_posts(:draft_post).title, response.body
  end

  test "show page displays tags and related posts" do
    post = blog_posts(:published_post)
    get blog_post_path(post)

    assert_response :success
    assert_select "a[href=?]", blog_posts_path(tag: "scrum"), text: /scrum/
    assert_select "a[href=?]", blog_posts_path(tag: "ai"), text: /ai/
    assert_match blog_posts(:related_post).title, response.body
  end

  test "show page hides edit button for guests" do
    get blog_post_path(blog_posts(:published_post))

    assert_response :success
    assert_select "a", text: "Edit Blog Post", count: 0
  end

  test "show page displays edit button for admin" do
    sign_in users(:admin)
    post = blog_posts(:published_post)
    get blog_post_path(post)

    assert_response :success
    assert_select "a[href=?]", edit_admin_blog_post_path(post), text: /Edit Post/, count: 2
  end
end
