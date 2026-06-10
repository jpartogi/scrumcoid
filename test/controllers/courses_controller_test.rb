require "test_helper"

class CoursesControllerTest < ActionDispatch::IntegrationTest
  test "lists published courses" do
    get courses_path

    assert_response :success
    assert_select "h3", text: courses(:ai_essentials).title
    assert_match courses(:ai_essentials).excerpt, response.body
    assert_match "USD 1,295", response.body
    assert_no_match courses(:draft_course).title, response.body
  end

  test "uses detected country currency when available" do
    get courses_path, headers: { "CF-IPCountry" => "US" }

    assert_response :success
    assert_match "USD 1,295", response.body
    assert_no_match "AUD 1,950", response.body
  end

  test "falls back to usd when detected currency is not available" do
    get courses_path, headers: { "CF-IPCountry" => "JP" }

    assert_response :success
    assert_match "USD 1,295", response.body
  end

  test "displays attached course logo" do
    course = courses(:ai_essentials)
    course.logo.attach(
      io: file_fixture("course-logo.png").open,
      filename: "course-logo.png",
      content_type: "image/png"
    )

    get courses_path

    assert_response :success
    assert_select "img[alt='#{course.title} logo']"
  end

  test "show page displays meta keywords when present" do
    course = courses(:ai_essentials)
    get course_path(course)

    assert_response :success
    assert_select "meta[name='keywords'][content='scrum, ai, essentials']"
  end

  test "show page displays related blog posts but not course tags" do
    course = courses(:ai_essentials)
    get course_path(course)

    assert_response :success
    assert_match blog_posts(:published_post).title, response.body
    assert_match blog_posts(:related_post).title, response.body
    assert_no_match "Topik", response.body
    assert_select "a[href=?]", blog_posts_path(tag: "scrum"), count: 0
  end

  test "show page hides edit button for guests" do
    get course_path(courses(:ai_essentials))

    assert_response :success
    assert_select "a[href=?]", edit_admin_course_path(courses(:ai_essentials)), count: 0
  end

  test "show page displays edit button for admin" do
    sign_in users(:admin)
    course = courses(:ai_essentials)
    get course_path(course)

    assert_response :success
    assert_select "a[href=?]", edit_admin_course_path(course), text: /Edit Course/, count: 2
  end
end
