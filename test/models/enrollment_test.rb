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

  test "course_history returns all enrollments for linked user across schedules" do
    student = users(:student)
    existing = enrollments(:existing_registration)
    other = Enrollment.create!(
      user: student,
      class_schedule: class_schedules(:closed_online),
      skip_registration_limits: true
    )

    history = existing.course_history

    assert_includes history, existing
    assert_includes history, other
    assert_equal 2, history.size
  ensure
    other&.destroy
  end

  test "course_history matches guest enrollments by email" do
    schedule_one = class_schedules(:open_online)
    schedule_two = class_schedules(:closed_online)

    enrollment_one = Enrollment.create!(
      class_schedule: schedule_one,
      first_name: "Guest",
      last_name: "Learner",
      email: "guest.learner@example.com",
      skip_registration_limits: true
    )
    enrollment_two = Enrollment.create!(
      class_schedule: schedule_two,
      first_name: "Guest",
      last_name: "Learner",
      email: "guest.learner@example.com",
      skip_registration_limits: true
    )

    history = enrollment_one.course_history

    assert_includes history, enrollment_one
    assert_includes history, enrollment_two
  ensure
    enrollment_one&.destroy
    enrollment_two&.destroy
  end

  test "matching_student_query finds enrollments by first name" do
    enrollment = Enrollment.create!(
      class_schedule: class_schedules(:open_online),
      first_name: "Jane",
      last_name: "Roster",
      email: "jane.roster@example.com",
      skip_registration_limits: true
    )

    assert_includes Enrollment.matching_student_query("Jane"), enrollment
    assert_not_includes Enrollment.matching_student_query("RosterOnly"), enrollment
  ensure
    enrollment&.destroy
  end

  test "matching_student_query finds enrollments by last name" do
    enrollment = Enrollment.create!(
      class_schedule: class_schedules(:open_online),
      first_name: "Jane",
      last_name: "Roster",
      email: "jane.roster@example.com",
      skip_registration_limits: true
    )

    assert_includes Enrollment.matching_student_query("Roster"), enrollment
    assert_not_includes Enrollment.matching_student_query("JaneOnly"), enrollment
  ensure
    enrollment&.destroy
  end

  test "matching_student_query finds account-linked enrollments by user first name" do
    enrollment = enrollments(:existing_registration)
    enrollment.update_columns(first_name: nil, last_name: nil)

    assert_includes Enrollment.matching_student_query("Student"), enrollment
    assert_not_includes Enrollment.matching_student_query("Nobody"), enrollment
  end

  test "for_course limits enrollments to the selected course" do
    enrollment = enrollments(:existing_registration)

    assert_includes Enrollment.for_course(courses(:ai_essentials).id), enrollment
    assert_not_includes Enrollment.for_course(courses(:draft_course).id), enrollment
  end

  test "with_schedule_starts_between filters enrollments by class schedule start date" do
    enrollment = enrollments(:existing_registration)
    schedule_date = enrollment.class_schedule.starts_at.to_date

    assert_includes Enrollment.with_schedule_starts_between(schedule_date - 1.day, schedule_date + 1.day), enrollment
    assert_not_includes Enrollment.with_schedule_starts_between(schedule_date + 10.days, schedule_date + 11.days), enrollment
  end

  test "ordered_for_admin sorts by company name using customer registration and enrollment values" do
    acme_enrollment = enrollments(:existing_registration)
    acme_enrollment.update!(company_name: "Acme Corp", registration: registrations(:one))

    globex_enrollment = Enrollment.create!(
      class_schedule: class_schedules(:open_online),
      registration: registrations(:two),
      first_name: "Bob",
      last_name: "Other",
      email: "bob@globex.com",
      company_name: "Globex",
      skip_registration_limits: true
    )

    companies = Enrollment.ordered_for_admin("company", "asc").map do |enrollment|
      enrollment.registration&.customer&.company_name.presence ||
        enrollment.registration&.company_name.presence ||
        enrollment.company_name
    end.compact_blank

    assert_operator companies.index("Acme Corp"), :<, companies.index("Globex")
  ensure
    globex_enrollment&.destroy
  end

  test "with_schedule_starts_between supports open-ended ranges" do
    enrollment = enrollments(:existing_registration)
    schedule_date = enrollment.class_schedule.starts_at.to_date

    assert_includes Enrollment.with_schedule_starts_between(schedule_date, nil), enrollment
    assert_not_includes Enrollment.with_schedule_starts_between(schedule_date + 1.day, nil), enrollment
    assert_includes Enrollment.with_schedule_starts_between(nil, schedule_date), enrollment
    assert_not_includes Enrollment.with_schedule_starts_between(nil, schedule_date - 1.day), enrollment
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