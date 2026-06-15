require "test_helper"

class InvitationMailerTest < ActionMailer::TestCase
  include ClassSchedulesHelper

  test "class invitation uses rendered course template" do
    enrollment = enrollments(:existing_registration)
    enrollment.update!(user: nil, first_name: "Jane", last_name: "Student", email: "jane@student.com")
    enrollment.class_schedule.course.update!(
      invitation_email: "Halo {{full_name}}, selamat datang di {{course_title}}."
    )

    schedule = enrollment.class_schedule
    expected_subject = "Undangan: #{enrollment.course.title} #{class_schedule_date_part(schedule)}"

    mail = InvitationMailer.class_invitation(enrollment)

    assert_equal ["jane@student.com"], mail.to
    assert_equal expected_subject, mail.subject
    assert_match "Halo Jane Student", mail.body.encoded
    assert_match enrollment.course.title, mail.body.encoded
  end

  test "class invitation accepts custom subject" do
    enrollment = enrollments(:existing_registration)
    enrollment.class_schedule.course.update!(invitation_email: "Halo {{full_name}}.")

    mail = InvitationMailer.class_invitation(enrollment, subject: "Custom Subject")

    assert_equal "Custom Subject", mail.subject
  end
end