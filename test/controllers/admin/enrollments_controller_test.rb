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

  test "admin can view course history for student with multiple enrollments" do
    sign_in users(:admin)
    enrollment = enrollments(:existing_registration)
    other_enrollment = Enrollment.create!(
      user: users(:student),
      class_schedule: class_schedules(:closed_online),
      skip_registration_limits: true
    )

    get admin_enrollment_path(enrollment)
    assert_response :success
    assert_select "h2", text: /Course History/
    assert_select "td", text: enrollment.class_schedule.course.title
    assert_select "td", text: other_enrollment.class_schedule.course.title
    assert_select "span", text: "Viewing"
  ensure
    other_enrollment&.destroy
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

  test "admin update redirects back to students page when edit came from students" do
    sign_in users(:admin)
    enrollment = enrollments(:existing_registration)
    students_path = admin_students_path(query: "Alice", sort: "student", direction: "asc")

    patch admin_enrollment_path(enrollment), params: {
      return_to: students_path,
      enrollment: {
        status: "cancelled"
      }
    }

    assert_redirected_to students_path
    assert enrollment.reload.cancelled?
  end

  test "admin update ignores unsafe return_to values" do
    sign_in users(:admin)
    enrollment = enrollments(:existing_registration)

    patch admin_enrollment_path(enrollment), params: {
      return_to: "//evil.example/admin/students",
      enrollment: {
        status: "cancelled"
      }
    }

    assert_redirected_to admin_class_schedule_path(enrollment.class_schedule)
  end

  test "student cannot delete enrollment" do
    sign_in users(:student)
    enrollment = enrollments(:existing_registration)

    assert_no_difference "Enrollment.count" do
      delete admin_enrollment_path(enrollment)
    end
    assert_redirected_to root_path
  end

  test "admin can delete enrollment" do
    sign_in users(:admin)
    enrollment = enrollments(:existing_registration)

    assert_difference "Enrollment.count", -1 do
      delete admin_enrollment_path(enrollment)
    end
    assert_redirected_to admin_class_schedule_path(enrollment.class_schedule)
  end

  test "admin can set company name on enrollment without existing company details" do
    sign_in users(:admin)
    enrollment = enrollments(:existing_registration)
    enrollment.update!(company_name: nil, registration: nil)

    get edit_admin_enrollment_path(enrollment)
    assert_response :success
    assert_select "input[name='enrollment[company_name]']"

    patch admin_enrollment_path(enrollment), params: {
      enrollment: {
        company_name: "New Company Ltd"
      }
    }

    assert_redirected_to admin_class_schedule_path(enrollment.class_schedule)
    assert_equal "New Company Ltd", enrollment.reload.company_name
  end

  test "admin can update company details directly on enrollment" do
    sign_in users(:admin)
    enrollment = enrollments(:existing_registration)

    patch admin_enrollment_path(enrollment), params: {
      enrollment: {
        company_name: "Overridden Corp Inc.",
        company_phone: "+62812345678",
        finance_name: "Finance Supervisor"
      }
    }

    assert_redirected_to admin_class_schedule_path(enrollment.class_schedule)
    enrollment.reload
    assert_equal "Overridden Corp Inc.", enrollment.company_name
    assert_equal "+62812345678", enrollment.company_phone
    assert_equal "Finance Supervisor", enrollment.finance_name
  end
end
