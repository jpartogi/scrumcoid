require "test_helper"

class Admin::ClassSchedulesControllerTest < ActionDispatch::IntegrationTest
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
