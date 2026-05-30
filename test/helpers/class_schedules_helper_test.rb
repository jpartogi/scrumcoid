require "test_helper"

class ClassSchedulesHelperTest < ActionView::TestCase
  include ClassSchedulesHelper

  test "formats multi-day class schedules in the same month and year" do
    schedule = ClassSchedule.new(
      starts_at: Time.zone.parse("2026-05-20 09:00:00"),
      ends_at: Time.zone.parse("2026-05-22 17:00:00"),
      timezone: "Etc/UTC"
    )
    assert_equal "20 - 22 May 2026 9:00 AM - 5:00 PM", formatted_class_date_range(schedule)
  end

  test "formats single-day class schedules" do
    schedule = ClassSchedule.new(
      starts_at: Time.zone.parse("2026-05-20 09:00:00"),
      ends_at: Time.zone.parse("2026-05-20 17:00:00"),
      timezone: "Etc/UTC"
    )
    assert_equal "20 May 2026 9:00 AM - 5:00 PM", formatted_class_date_range(schedule)
  end

  test "formats spanning months class schedules" do
    schedule = ClassSchedule.new(
      starts_at: Time.zone.parse("2026-05-30 09:00:00"),
      ends_at: Time.zone.parse("2026-06-01 17:00:00"),
      timezone: "Etc/UTC"
    )
    assert_equal "30 May 2026, 9:00 AM - 1 June 2026, 5:00 PM", formatted_class_date_range(schedule)
  end

  test "renders local time data for browser timezone conversion" do
    schedule = class_schedules(:open_online)

    html = local_class_time(schedule, format: :range)

    assert_includes html, "data-controller=\"local-time\""
    assert_includes html, "data-local-time-start-value="
    assert_includes html, "data-local-time-end-value="
    assert_includes html, "data-local-time-format-value=\"range\""
  end

  test "formats admin datetime fields in schedule timezone" do
    starts_at = Time.find_zone("Australia/Brisbane").parse("2026-05-20 09:00:00")
    schedule = ClassSchedule.new(starts_at: starts_at, timezone: "Australia/Brisbane")

    assert_equal "2026-05-20T09:00", class_schedule_time_field_value(schedule, :starts_at)
  end
end
