require "test_helper"

class SitemapsControllerTest < ActionDispatch::IntegrationTest
  test "renders sitemap successfully with correct format" do
    get "/sitemap.xml"

    assert_response :success
    assert_equal "application/xml; charset=utf-8", response.content_type
    
    # Assert presence of XML layout tags
    assert_match "<urlset", response.body
    assert_match "<loc>", response.body

    # Assert presence of static pages
    assert_match root_url, response.body
    assert_match about_url, response.body
    assert_match new_contact_url, response.body

    # Assert presence of resource indexes
    assert_match courses_url, response.body
    assert_match class_schedules_url, response.body
    assert_match resources_url, response.body
    assert_match blog_posts_url, response.body

    # Assert presence of dynamic models
    assert_match course_url(courses(:ai_essentials)), response.body
    assert_match class_schedule_url(class_schedules(:open_online)), response.body
    assert_match %r{/class_schedules/#{courses(:ai_essentials).slug}/#{class_schedules(:open_online).id}}, response.body
    assert_no_match %r{/class_schedules/#{class_schedules(:closed_online).id}(?:<|/)}, response.body
    assert_match resource_url(resources(:published_resource)), response.body
    assert_match blog_post_url(blog_posts(:published_post)), response.body
  end

  test "serves robots.txt successfully with crawler directives" do
    get "/robots.txt"

    assert_response :success
    assert_match "User-agent: *", response.body
    assert_match "Disallow: /admin/", response.body
    assert_match "Disallow: /dashboard/", response.body
    assert_match "Disallow: /users/", response.body
    assert_match "Sitemap: https://scrum.co.id/sitemap.xml", response.body
  end
end
