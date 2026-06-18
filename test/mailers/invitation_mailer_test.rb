require "test_helper"

class InvitationMailerTest < ActionMailer::TestCase
  include ActionDispatch::TestProcess
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

    # Verify that the tracking pixel was rendered
    html_content = mail.html_part.decoded
    assert_match "/invitations/track/#{enrollment.reload.invitation_token}", html_content
    assert_match "width=\"1\" height=\"1\"", html_content
  end

  test "class invitation accepts custom subject" do
    enrollment = enrollments(:existing_registration)
    enrollment.class_schedule.course.update!(invitation_email: "Halo {{full_name}}.")

    mail = InvitationMailer.class_invitation(enrollment, subject: "Custom Subject")

    assert_equal "Custom Subject", mail.subject
  end

  test "class invitation test delivers to specified address using roster sample data" do
    enrollment = enrollments(:existing_registration)
    enrollment.update!(user: nil, first_name: "Jane", last_name: "Student", email: "jane@student.com")
    enrollment.class_schedule.course.update!(invitation_email: "Halo {{full_name}}.")

    mail = InvitationMailer.class_invitation_test(
      enrollment.class_schedule_id,
      subject: "Test Subject",
      to: "tester@example.com"
    )

    assert_equal ["tester@example.com"], mail.to
    assert_equal "Test Subject", mail.subject
    assert_match "Halo Jane Student", mail.body.encoded
  end

  test "class invitation renders thumbnail when attached" do
    enrollment = enrollments(:existing_registration)
    course = enrollment.course
    thumbnail = fixture_file_upload("course-logo.png", "image/png")
    course.thumbnail.attach(thumbnail)

    mail = InvitationMailer.class_invitation(enrollment)

    assert course.thumbnail.attached?
    html_content = mail.html_part.decoded
    assert_match "rails/active_storage/blobs", html_content
    assert_match "course-logo.png", html_content
  end

  test "class invitation renders logo when attached and no thumbnail" do
    enrollment = enrollments(:existing_registration)
    course = enrollment.course
    course.thumbnail.purge if course.thumbnail.attached?
    logo = fixture_file_upload("course-logo.png", "image/png")
    course.logo.attach(logo)

    mail = InvitationMailer.class_invitation(enrollment)

    assert course.logo.attached?
    refute course.thumbnail.attached?
    html_content = mail.html_part.decoded
    assert_match "rails/active_storage/blobs", html_content
    assert_match "course-logo.png", html_content
  end
end