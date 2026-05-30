require "test_helper"

class EnrollmentTest < ActiveSupport::TestCase
  test "prevents duplicate registration" do
    enrollment = Enrollment.new(user: users(:student), class_schedule: class_schedules(:open_online))

    assert_not enrollment.valid?
    assert_includes enrollment.errors[:user_id], "has already been taken"
  end

  test "prevents registration when schedule is full" do
    enrollment = Enrollment.new(user: users(:student), class_schedule: class_schedules(:full_online))

    assert_not enrollment.valid?
    assert_includes enrollment.errors[:class_schedule], "is full"
  end

  test "prevents registration when schedule is closed" do
    enrollment = Enrollment.new(user: users(:student), class_schedule: class_schedules(:closed_online))

    assert_not enrollment.valid?
    assert_includes enrollment.errors[:class_schedule], "is closed for registration"
  end

  test "allows pending visitor enrollment without linked user" do
    enrollment = Enrollment.new(
      class_schedule: class_schedules(:open_online),
      visitor_email: "visitor@example.com",
      visitor_name: "Visitor Person"
    )

    assert enrollment.valid?
    assert_equal "Visitor Person", enrollment.attendee_name
    assert_equal "visitor@example.com", enrollment.attendee_email
  end

  test "requires visitor email when user is not linked" do
    enrollment = Enrollment.new(class_schedule: class_schedules(:open_online), visitor_name: "Visitor Person")

    assert_not enrollment.valid?
    assert_includes enrollment.errors[:visitor_email], "can't be blank"
  end
end
