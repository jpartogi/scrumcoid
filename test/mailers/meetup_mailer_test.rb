require "test_helper"

class MeetupMailerTest < ActionMailer::TestCase
  test "confirmation includes join link and ics attachment" do
    registration = meetup_registrations(:confirmed_visitor)
    mail = MeetupMailer.confirmation(registration)

    assert_equal [registration.visitor_email], mail.to
    assert_match registration.meetup.slug, mail.subject
    assert_match registration.meetup.join_link, mail.body.encoded
    assert_match /\.ics$/, mail.attachments.first.filename
    assert_equal "text/calendar", mail.attachments.first.mime_type
    assert_includes mail.attachments.first.body.raw_source, "BEGIN:VCALENDAR"
    assert_includes mail.attachments.first.body.raw_source, registration.meetup.slug
  end

  test "follow_up includes paypal donation link" do
    registration = meetup_registrations(:pending_follow_up)
    mail = MeetupMailer.follow_up(registration)

    assert_equal [registration.visitor_email], mail.to
    assert_match "hosted_button_id", mail.body.encoded
    assert_match "TEST456", mail.body.encoded
    assert_match "PayPal", mail.body.encoded
    body = mail.text_part.body.decoded
    assert_includes body, "http://example.com/meetups"
    next_meetup = Meetup.published.upcoming.where.not(id: registration.meetup_id).first
    assert_includes body, next_meetup.display_name
    assert_includes body, "meetup berikutnya"
  end
end