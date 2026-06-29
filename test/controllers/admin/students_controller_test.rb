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

  test "admin can filter students by course" do
    sign_in @admin

    get admin_students_path, params: { course_id: courses(:ai_essentials).id }
    assert_response :success
    assert_select "td", text: /Scrum.org AI Essentials/
    assert_select "select[name='course_id'] option[selected][value='#{courses(:ai_essentials).id}']"

    get admin_students_path, params: { course_id: courses(:draft_course).id }
    assert_response :success
    assert_select "td", text: /Student User/, count: 0
  end

  test "search query shows record count at bottom of table" do
    sign_in @admin

    get admin_students_path, params: { query: "Alice" }

    assert_response :success
    assert_select "nav[aria-label='Pagination']", count: 0
    assert_match(/Showing \d+–\d+ of \d+ student/, response.body)
  end

  test "admin can filter students by schedule date range" do
    sign_in @admin
    schedule_date = @enrollment.class_schedule.starts_at.to_date

    get admin_students_path, params: {
      starts_on_from: schedule_date - 1.day,
      starts_on_to: schedule_date + 1.day
    }

    assert_response :success
    assert_select "td", text: /Student User/
    assert_select "input[name='starts_on_from'][value='#{(schedule_date - 1.day).iso8601}']"
    assert_select "input[name='starts_on_to'][value='#{(schedule_date + 1.day).iso8601}']"

    get admin_students_path, params: {
      starts_on_from: schedule_date + 10.days,
      starts_on_to: schedule_date + 11.days
    }

    assert_response :success
    assert_select "td", text: /Student User/, count: 0
    assert_select "p", text: /No students found/
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

  test "index lists students with sortable headers" do
    sign_in @admin
    get admin_students_path

    assert_response :success
    assert_select "a[href*='sort=student']", text: /Student/
    assert_select "a[href*='sort=company']", text: /Company/
    assert_select "a[href*='sort=training_schedule']", text: /Training Schedule/
  end

  test "index sorts by company ascending" do
    sign_in @admin

    globex_enrollment = Enrollment.create!(
      class_schedule: class_schedules(:open_online),
      registration: registrations(:two),
      first_name: "Bob",
      last_name: "Other",
      email: "bob@globex.com",
      company_name: "Globex",
      skip_registration_limits: true
    )

    get admin_students_path(sort: "company", direction: "asc")

    assert_response :success
    assert_select "a[href*='sort=company'][href*='direction=desc']"

    acme_index = response.body.index("Acme Corp")
    globex_index = response.body.index("Globex")

    assert_operator acme_index, :<, globex_index
  ensure
    globex_enrollment&.destroy
  end

  test "index sorts by student ascending" do
    sign_in @admin
    @enrollment.update_columns(user_id: nil)

    other_enrollment = Enrollment.create!(
      class_schedule: class_schedules(:open_online),
      registration: registrations(:two),
      first_name: "Zara",
      last_name: "Zulu",
      email: "zara@example.com",
      company_name: "Globex",
      skip_registration_limits: true
    )

    get admin_students_path(sort: "student", direction: "asc")

    assert_response :success
    assert_select "a[href*='sort=student'][href*='direction=desc']"

    admin_index = response.body.index("Admin User")
    alice_index = response.body.index("Alice Student")
    zara_index = response.body.index("Zara Zulu")

    assert_operator admin_index, :<, alice_index
    assert_operator alice_index, :<, zara_index
  ensure
    other_enrollment&.destroy
    @enrollment.update_columns(user_id: users(:student).id)
  end

  test "index sorts by training schedule descending" do
    sign_in @admin

    earlier_schedule = ClassSchedule.create!(
      course: courses(:ai_essentials),
      starts_at: 10.days.from_now,
      ends_at: 10.days.from_now + 8.hours,
      location: "Live online via Zoom",
      online: true,
      timezone: "Etc/UTC",
      registration_deadline: 5.days.from_now,
      capacity: 20,
      status: :published
    )
    later_enrollment = Enrollment.create!(
      class_schedule: earlier_schedule,
      registration: registrations(:two),
      first_name: "Earlier",
      last_name: "Schedule",
      email: "earlier@example.com",
      company_name: "Globex",
      skip_registration_limits: true
    )

    get admin_students_path(sort: "training_schedule", direction: "desc")

    assert_response :success
    assert_select "a[href*='sort=training_schedule'][href*='direction=asc']"

    open_online_index = response.body.index(class_schedules(:open_online).starts_at.strftime("%d %b"))
    earlier_index = response.body.index(earlier_schedule.starts_at.strftime("%d %b"))

    assert_operator open_online_index, :<, earlier_index
  ensure
    later_enrollment&.destroy
    earlier_schedule&.destroy
  end
end