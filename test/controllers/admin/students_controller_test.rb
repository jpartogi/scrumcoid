require "test_helper"

class Admin::StudentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @student_user = users(:student)
    @registration = registrations(:one)
    @enrollment = enrollments(:existing_registration)
    @enrollment.update!(
      registration: @registration,
      first_name: "Alice",
      last_name: "Student",
      email: "alice@acme.com",
      company_name: "Acme Corp"
    )
  end

  test "guest cannot access students index" do
    get admin_students_path
    assert_redirected_to new_user_session_path
  end

  test "admin can get students index" do
    sign_in @admin
    get admin_students_path
    assert_response :success
    assert_select "h1", "CRM / Student Management"
    assert_select "a[href=?]", admin_customers_path, text: /Customers/
    assert_select "a[href=?]", admin_students_path, text: /Students/
    assert_select "td", text: /Student User/
  end

  test "admin can search students by name" do
    sign_in @admin

    other_enrollment = Enrollment.create!(
      class_schedule: class_schedules(:open_online),
      registration: registrations(:two),
      first_name: "Bob",
      last_name: "Other",
      email: "bob@globex.com",
      company_name: "Globex",
      skip_registration_limits: true
    )

    get admin_students_path, params: { query: "Alice" }
    assert_response :success
    assert_select "td", text: /Student User/
    assert_select "td", text: /Bob/, count: 0
  ensure
    other_enrollment&.destroy
  end

  test "admin can search students by company" do
    sign_in @admin
    get admin_students_path, params: { query: "Acme" }
    assert_response :success
    assert_select "td", text: /Acme Corp/
  end

  test "customers index includes CRM tabs linking to students" do
    sign_in @admin
    get admin_customers_path
    assert_response :success
    assert_select "a[href=?]", admin_students_path, text: /Students/
  end
end