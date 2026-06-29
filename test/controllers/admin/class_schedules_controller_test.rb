require "test_helper"

class Admin::ClassSchedulesControllerTest < ActionDispatch::IntegrationTest
  test "index shows only upcoming schedules by default" do
    sign_in users(:admin)

    get admin_class_schedules_path
    assert_response :success

    assert_select "a[href=?]", admin_class_schedule_path(class_schedules(:open_online))
    assert_select "a[href=?]", admin_class_schedule_path(class_schedules(:past_online)), count: 0
    assert_select "a[href=?]", admin_class_schedules_path(past: 1), text: /Past Schedules/
  end

  test "index with past param shows only past schedules" do
    sign_in users(:admin)

    get admin_class_schedules_path(past: 1)
    assert_response :success

    assert_select "h1", text: "Past Class Schedules"
    assert_select "a[href=?]", admin_class_schedule_path(class_schedules(:past_online))
    assert_select "a[href=?]", admin_class_schedule_path(class_schedules(:open_online)), count: 0
    assert_select "a[href=?]", admin_class_schedules_path, text: /Upcoming Schedules/
  end

  test "show page includes batch size form for adding students" do
    sign_in users(:admin)
    schedule = class_schedules(:open_online)

    get admin_class_schedule_path(schedule)
    assert_response :success
    assert_select "input[name='count'][type=number]"
    assert_select "input[type=submit][value='Add Students']"
  end

  test "show page includes export to csv button" do
    sign_in users(:admin)
    schedule = class_schedules(:open_online)

    get admin_class_schedule_path(schedule)
    assert_response :success
    assert_select "a[href=?]", export_enrollments_admin_class_schedule_path(schedule), text: "Export to CSV"
  end

  test "admin can export registered students as csv" do
    sign_in users(:admin)
    schedule = class_schedules(:open_online)
    enrollment = enrollments(:existing_registration)

    get export_enrollments_admin_class_schedule_path(schedule)
    assert_response :success
    assert_equal "text/csv", response.media_type
    assert_match(/attachment; filename="#{schedule.course.slug}-\d{4}-\d{2}-\d{2}-roster.csv"/, response.headers["Content-Disposition"])

    rows = CSV.parse(response.body)
    assert_equal EnrollmentRosterCsvExporter::HEADERS, rows.first
    assert rows.any? { |row| row[1] == enrollment.attendee_email }
  end

  test "guest cannot export registered students as csv" do
    schedule = class_schedules(:open_online)

    get export_enrollments_admin_class_schedule_path(schedule)
    assert_redirected_to new_user_session_path
  end

  test "admin creates schedule times in selected timezone" do
    sign_in users(:admin)

    assert_difference -> { ClassSchedule.count }, 1 do
      post admin_class_schedules_path, params: {
        class_schedule: {
          course_id: courses(:ai_essentials).id,
          starts_at: "2026-06-01T09:00",
          ends_at: "2026-06-01T17:00",
          registration_deadline: "2026-05-25T17:00",
          timezone: "Australia/Brisbane",
          location: "Brisbane, Australia",
          online: false,
          capacity: 20,
          status: "published",
          venue_id: venues(:brisbane_hub).id
        }
      }
    end

    schedule = ClassSchedule.order(:created_at).last
    assert_redirected_to admin_class_schedule_path(schedule)
    assert_equal "Australia/Brisbane", schedule.timezone
    assert_equal Time.find_zone("Australia/Brisbane").parse("2026-06-01 09:00"), schedule.starts_at
    assert_equal Time.find_zone("Australia/Brisbane").parse("2026-06-01 17:00"), schedule.ends_at
    assert_equal "Brisbane Training Hub", schedule.venue_name
    assert_equal "123 Queen St, Brisbane QLD 4000", schedule.venue_address
  end
end
