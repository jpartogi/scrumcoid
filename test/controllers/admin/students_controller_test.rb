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

  test "admin can search students by first name" do
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

  test "admin can search account-linked students by displayed first name" do
    sign_in @admin
    @enrollment.update_columns(first_name: nil, last_name: nil)

    get admin_students_path, params: { query: "Student" }
    assert_response :success
    assert_select "td", text: /Student User/
  end

  test "admin can search students by last name" do
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

    get admin_students_path, params: { query: "Other" }
    assert_response :success
    assert_select "td", text: /Bob/
    assert_select "td", text: /Student User/, count: 0
  ensure
    other_enrollment&.destroy
  end

  test "admin can search students by company" do
    sign_in @admin
    get admin_students_path, params: { query: "Acme" }
    assert_response :success
    assert_select "td", text: /Acme Corp/
  end

  test "index paginates students and respects per_page parameter" do
    sign_in @admin
    @original_per_page = PaginatedScope.default_per_page
    PaginatedScope.default_per_page = 1

    get admin_students_path(per_page: 1)

    assert_response :success
    assert_select "input[name='per_page'][value='1']"
    assert_select "nav[aria-label='Pagination']"
  ensure
    PaginatedScope.default_per_page = @original_per_page
  end

  test "index paginates filtered students by search query" do
    sign_in @admin
    @original_per_page = PaginatedScope.default_per_page
    PaginatedScope.default_per_page = 1

    other_enrollment = Enrollment.create!(
      class_schedule: class_schedules(:open_online),
      registration: registrations(:two),
      first_name: "Bob",
      last_name: "Other",
      email: "bob@globex.com",
      company_name: "Globex",
      skip_registration_limits: true
    )

    get admin_students_path, params: { query: "Alice", per_page: 1, page: 1 }

    assert_response :success
    assert_select "nav[aria-label='Pagination']", count: 0
    assert_select "td", text: /Student User/
    assert_select "td", text: /Bob/, count: 0
  ensure
    other_enrollment&.destroy
    PaginatedScope.default_per_page = @original_per_page
  end

  test "customers index includes CRM tabs linking to students" do
    sign_in @admin
    get admin_customers_path
    assert_response :success
    assert_select "a[href=?]", admin_students_path, text: /Students/
  end
end