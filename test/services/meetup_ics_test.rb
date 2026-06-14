require "test_helper"

class MeetupIcsTest < ActiveSupport::TestCase
  setup do
    @registration = meetup_registrations(:confirmed_visitor)
    @meetup = @registration.meetup
  end

  test "generates valid calendar event content" do
    ics = MeetupIcs.generate(@registration)

    assert_includes ics, "BEGIN:VCALENDAR"
    assert_includes ics, "BEGIN:VEVENT"
    assert_includes ics, "END:VEVENT"
    assert_includes ics, "END:VCALENDAR"
    assert_includes ics, "METHOD:PUBLISH"
    assert_includes ics, "UID:meetup-#{@meetup.id}-registration-#{@registration.id}@scrum.co.id"
    assert_includes ics, "DTSTART;TZID=Asia/Jakarta:"
    assert_includes ics, "DTEND;TZID=Asia/Jakarta:"
    assert_includes ics, "SUMMARY:Scrum.co.id Meetup #{@meetup.slug}"
    assert_includes ics, @meetup.join_link
    assert_includes ics, @registration.visitor_name
  end
end