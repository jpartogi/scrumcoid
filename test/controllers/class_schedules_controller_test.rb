require "test_helper"

class ClassSchedulesControllerTest < ActionDispatch::IntegrationTest
  test "displays schedule price in euro for EU visitors" do
    get class_schedules_path, headers: { "CF-IPCountry" => "DE" }

    assert_response :success
    assert_match "EUR 1,195", response.body
  end

  test "falls back to usd schedule price when visitor currency is unavailable" do
    get class_schedules_path, headers: { "CF-IPCountry" => "JP" }

    assert_response :success
    assert_match "USD 1,295", response.body
  end

  test "register link directs to new registration form" do
    get class_schedule_path(class_schedules(:open_online))

    assert_response :success
    assert_select "a[href='#{new_class_schedule_registration_path(class_schedules(:open_online))}']"
  end

  test "show page displays meta keywords from associated course" do
    schedule = class_schedules(:open_online)
    get class_schedule_path(schedule)

    assert_response :success
    assert_select "meta[name='keywords'][content='scrum, ai, essentials']"
  end

  test "show page displays related blog posts and other schedules for the same course" do
    schedule = class_schedules(:open_online)
    other_schedule = class_schedules(:full_online)
    get class_schedule_path(schedule)

    assert_response :success
    assert_select "#other-schedules"
    assert_select "#other-schedules a[href='#{class_schedule_path(other_schedule)}']"
    assert_match blog_posts(:published_post).title, response.body
    assert_match blog_posts(:related_post).title, response.body
    assert_no_match "Topik", response.body
  end

  test "show page hides edit button for guests" do
    get class_schedule_path(class_schedules(:open_online))

    assert_response :success
    assert_select "a[href=?]", edit_admin_class_schedule_path(class_schedules(:open_online)), count: 0
  end

  test "show page displays edit button for admin" do
    sign_in users(:admin)
    schedule = class_schedules(:open_online)
    get class_schedule_path(schedule)

    assert_response :success
    assert_select "a[href=?]", edit_admin_class_schedule_path(schedule), text: /Edit Schedule/, count: 2
  end
end
