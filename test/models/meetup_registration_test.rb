require "test_helper"

class MeetupRegistrationTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test "requires visitor email and name" do
    registration = MeetupRegistration.new(meetup: meetups(:open_meetup))

    assert_not registration.valid?
    assert_includes registration.errors[:visitor_name], "can't be blank"
    assert_includes registration.errors[:visitor_email], "can't be blank"
  end

  test "prevents duplicate email for same meetup" do
    registration = MeetupRegistration.new(
      meetup: meetups(:open_meetup),
      visitor_name: "Another Budi",
      visitor_email: "budi@example.com"
    )

    assert_not registration.valid?
    assert_includes registration.errors[:visitor_email], "has already been taken"
  end

  test "send_confirmation_email enqueues mail and timestamps" do
    registration = MeetupRegistration.create!(
      meetup: meetups(:open_meetup),
      visitor_name: "New Visitor",
      visitor_email: "new@example.com"
    )

    assert_enqueued_emails 1 do
      registration.send_confirmation_email!
    end

    assert_not_nil registration.reload.confirmation_email_sent_at
  end

  test "send_follow_up_email enqueues mail when donation url is present" do
    registration = meetup_registrations(:pending_follow_up)

    assert_enqueued_emails 1 do
      registration.send_follow_up_email!
    end

    assert_not_nil registration.reload.follow_up_email_sent_at
  end
end