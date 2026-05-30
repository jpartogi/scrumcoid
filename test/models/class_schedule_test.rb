require "test_helper"

class ClassScheduleTest < ActiveSupport::TestCase
  test "reports remaining seats from active enrollments" do
    schedule = class_schedules(:open_online)

    assert_equal 1, schedule.registration_count
    assert_equal 1, schedule.remaining_seats
    assert schedule.available_for_registration?
  end

  test "full schedule is not available for registration" do
    schedule = class_schedules(:full_online)

    assert schedule.full?
    assert_not schedule.available_for_registration?
  end

  test "defaults timezone when blank" do
    schedule = class_schedules(:open_online)
    schedule.timezone = nil

    assert schedule.valid?
    assert_equal "Australia/Brisbane", schedule.timezone
  end

  test "requires valid timezone" do
    schedule = class_schedules(:open_online)
    schedule.timezone = "Not/AZone"

    assert_not schedule.valid?
    assert_includes schedule.errors[:timezone], "must be a valid time zone"
  end

  test "displays preferred schedule price by currency" do
    schedule = class_schedules(:open_online)

    assert_equal "EUR 1195.00", schedule.display_price_for("EUR")
  end

  test "falls back to usd schedule price" do
    schedule = class_schedules(:open_online)

    assert_equal "USD 1295.00", schedule.display_price_for("JPY")
  end
end
