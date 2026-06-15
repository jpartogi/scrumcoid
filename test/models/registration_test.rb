require "test_helper"

class RegistrationTest < ActiveSupport::TestCase
  test "automatically assigns class_schedule to nested enrollments" do
    schedule = class_schedules(:open_online)
    registration = Registration.new(
      class_schedule: schedule,
      company_name: "Test Company",
      finance_name: "Finance Manager",
      finance_email: "finance@company.com"
    )
    registration.enrollments.build(first_name: "Participant", last_name: "One", email: "one@company.com")
    registration.enrollments.build(first_name: "Participant", last_name: "Two", email: "two@company.com")

    assert registration.valid?
    registration.enrollments.each do |enrollment|
      assert_equal schedule, enrollment.class_schedule
    end
  end
end