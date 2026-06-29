require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "requires admin access" do
    sign_in users(:student)

    get admin_root_path

    assert_redirected_to root_path
  end

  test "allows admin access" do
    sign_in users(:admin)

    get admin_root_path

    assert_response :success
    assert_select "h1", "Admin dashboard"
    assert_select "#admin-user-section", text: /#{users(:admin).name}/
    assert_select "a[href='#{edit_user_registration_path}']", text: "Settings"
    assert_select "footer", text: /Scrum.co.id Admin/
    assert_no_match "Professional Scrum training for teams", response.body
    
    # Assert visitor statistics are displayed
    assert_select "p", text: "Today's Visitors"
    assert_select "h2", text: /Visitor Traffic \(7 Days\)/
    assert_select "p", text: "Total Downloads"
    assert_select "p", text: "Unread Mail", count: 0
    assert_select ".grid.gap-4 .rounded-2xl", count: 6
  end

  test "live classes and total bookings exclude past schedules" do
    sign_in users(:admin)

    past_enrollment = Enrollment.create!(
      class_schedule: class_schedules(:past_online),
      first_name: "Past",
      last_name: "Student",
      email: "past.student@example.com",
      skip_registration_limits: true
    )

    get admin_root_path
    assert_response :success

    live_classes_label = css_select("p").find { |element| element.text.strip == "Live Classes" }
    bookings_label = css_select("p").find { |element| element.text.strip == "Total Bookings" }

    assert_equal ClassSchedule.published.upcoming.count.to_s,
      live_classes_label.parent.at_css("p.text-3xl").text.strip
    assert_equal Enrollment.active.joins(:class_schedule).merge(ClassSchedule.upcoming).count.to_s,
      bookings_label.parent.at_css("p.text-3xl").text.strip
    assert_not_includes Enrollment.active.joins(:class_schedule).merge(ClassSchedule.upcoming).pluck(:id), past_enrollment.id
  ensure
    past_enrollment&.destroy
  end

  test "admin dashboard displays latest five registrations" do
    sign_in users(:admin)

    get admin_root_path

    assert_response :success
    assert_select "h2", text: /Latest Registrations/
    assert_select "td", text: /Acme Corp/
  end
end
