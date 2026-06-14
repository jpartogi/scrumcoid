require "test_helper"

class MeetupMailerTest < ActionMailer::TestCase
  test "confirmation includes join link" do
    registration = meetup_registrations(:confirmed_visitor)
    mail = MeetupMailer.confirmation(registration)

    assert_equal [registration.visitor_email], mail.to
    assert_match registration.meetup.slug, mail.subject
    assert_match registration.meetup.join_link, mail.body.encoded
  end

  test "follow_up includes paypal donation link" do
    registration = meetup_registrations(:pending_follow_up)
    mail = MeetupMailer.follow_up(registration)

    assert_equal [registration.visitor_email], mail.to
    assert_match "hosted_button_id", mail.body.encoded
    assert_match "TEST456", mail.body.encoded
    assert_match "PayPal", mail.body.encoded
  end
end