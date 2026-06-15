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
      first_name: "Visitor",
      last_name: "Person",
      email: "visitor@example.com",
      country: "Indonesia"
    )

    assert enrollment.valid?
    assert_equal "Visitor Person", enrollment.attendee_name
    assert_equal "visitor@example.com", enrollment.attendee_email
  end

  test "requires visitor fields when user is not linked" do
    enrollment = Enrollment.new(class_schedule: class_schedules(:open_online), first_name: "Visitor")

    assert_not enrollment.valid?
    assert_includes enrollment.errors[:last_name], "can't be blank"
    assert_includes enrollment.errors[:email], "can't be blank"
  end

  test "copies company details from registration on validation" do
    registration = registrations(:one)
    enrollment = Enrollment.new(
      class_schedule: class_schedules(:open_online),
      first_name: "John",
      last_name: "Doe",
      email: "john.doe@example.com",
      registration: registration
    )

    assert enrollment.valid?
    assert_equal registration.company_name, enrollment.company_name
    assert_equal registration.company_address, enrollment.company_address
    assert_equal registration.company_phone, enrollment.company_phone
    assert_equal registration.finance_name, enrollment.finance_name
    assert_equal registration.finance_email, enrollment.finance_email
  end

  test "allows duplicate visitor email registrations on the same schedule" do
    schedule = class_schedules(:open_online)
    schedule.update!(capacity: 10)

    enrollment1 = Enrollment.new(
      class_schedule: schedule,
      first_name: "Visitor",
      last_name: "One",
      email: "duplicate@example.com"
    )
    assert enrollment1.valid?
    enrollment1.save!

    enrollment2 = Enrollment.new(
      class_schedule: schedule,
      first_name: "Visitor",
      last_name: "Two",
      email: "duplicate@example.com"
    )
    assert enrollment2.valid?
  end

  test "bypasses schedule limits when skip_registration_limits is set" do
    enrollment = Enrollment.new(
      class_schedule: class_schedules(:full_online),
      first_name: "Admin",
      last_name: "Added",
      email: "admin-added@example.com"
    )
    enrollment.skip_registration_limits = true

    assert enrollment.valid?
  end
end