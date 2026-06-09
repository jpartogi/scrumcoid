require "test_helper"

class CourseTest < ActiveSupport::TestCase
  test "tag_list parses comma-separated tags" do
    course = courses(:ai_essentials)

    assert_equal ["scrum", "ai"], course.tag_list
  end

  test "related_blog_posts returns published posts sharing at least one tag" do
    course = courses(:ai_essentials)
    related = course.related_blog_posts

    assert_includes related, blog_posts(:published_post)
    assert_includes related, blog_posts(:related_post)
    assert_not_includes related, blog_posts(:draft_post)
  end

  test "related_blog_posts returns none when course has no tags" do
    course = courses(:draft_course)

    assert_empty course.related_blog_posts
  end
end