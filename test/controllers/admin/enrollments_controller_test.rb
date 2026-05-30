require "test_helper"

class Admin::EnrollmentsControllerTest < ActionDispatch::IntegrationTest
  test "student cannot access admin enrollments" do
    sign_in users(:student)
    enrollment = enrollments(:existing_registration)

    get admin_enrollment_path(enrollment)
    assert_redirected_to root_path

    get edit_admin_enrollment_path(enrollment)
    assert_redirected_to root_path
  end

  test "admin can view enrollment details" do
    sign_in users(:admin)
    enrollment = enrollments(:existing_registration)

    get admin_enrollment_path(enrollment)
    assert_response :success
    assert_select "h1", "Student Registration"
    assert_match enrollment.attendee_name, response.body
  end

  test "admin can view edit registration form" do
    sign_in users(:admin)
    enrollment = enrollments(:existing_registration)

    get edit_admin_enrollment_path(enrollment)
    assert_response :success
    assert_select "h1", "Edit Student Registration"
  end

  test "admin can update registration details" do
    sign_in users(:admin)
    enrollment = enrollments(:existing_registration)

    patch admin_enrollment_path(enrollment), params: {
      enrollment: {
        status: "cancelled"
      }
    }

    assert_redirected_to admin_class_schedule_path(enrollment.class_schedule)
    assert enrollment.reload.cancelled?
  end
end
