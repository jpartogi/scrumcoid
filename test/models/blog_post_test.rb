require "test_helper"

class BlogPostTest < ActiveSupport::TestCase
  test "tag_list parses comma-separated tags" do
    post = blog_posts(:published_post)

    assert_equal ["scrum", "ai"], post.tag_list
  end

  test "with_tag finds posts by tag case-insensitively" do
    posts = BlogPost.with_tag("SCRUM")

    assert_includes posts, blog_posts(:published_post)
    assert_includes posts, blog_posts(:related_post)
    assert_not_includes posts, blog_posts(:draft_post)
  end

  test "related_by_tags returns posts sharing at least one tag" do
    post = blog_posts(:published_post)
    related = post.related_by_tags

    assert_includes related, blog_posts(:related_post)
    assert_not_includes related, post
  end

  test "all_tags returns unique sorted tags from published posts" do
    assert_equal ["agile", "ai", "scrum"], BlogPost.all_tags
  end
end