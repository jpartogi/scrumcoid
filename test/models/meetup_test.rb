require "test_helper"

class MeetupTest < ActiveSupport::TestCase
  test "available_for_registration when published with seats and open deadline" do
    meetup = meetups(:open_meetup)

    assert meetup.available_for_registration?
  end

  test "rejects multi-day events" do
    meetup = meetups(:open_meetup)
    meetup.ends_at = meetup.starts_at + 2.days

    assert_not meetup.valid?
    assert_includes meetup.errors[:ends_at], "must be on the same day as the start time"
  end

  test "registration_count counts active registrations only" do
    meetup = meetups(:open_meetup)

    assert_equal 1, meetup.registration_count
  end

  test "donation_url falls back to environment variable" do
    meetup = meetups(:open_meetup)
    meetup.paypal_donation_url = nil

    with_env("PAYPAL_DONATION_URL" => "https://paypal.example/donate") do
      assert_equal "https://paypal.example/donate", meetup.donation_url
    end
  end

  test "generates slug from meetup date with sequential suffix" do
    time_zone = Time.find_zone!(Meetup::DEFAULT_TIMEZONE)
    starts_at = time_zone.local(2026, 6, 14, 19, 0, 0)
    ends_at = starts_at.change(hour: 21)

    first = Meetup.new(
      excerpt: "First session",
      description: "Details",
      starts_at: starts_at,
      ends_at: ends_at,
      registration_deadline: starts_at - 1.day,
      timezone: Meetup::DEFAULT_TIMEZONE,
      capacity: 50,
      status: :published
    )

    assert first.save!
    assert_equal "2026-06-14-1", first.slug

    second = Meetup.new(
      excerpt: "Second session",
      description: "Details",
      starts_at: starts_at.change(hour: 17),
      ends_at: starts_at.change(hour: 18),
      registration_deadline: starts_at - 1.day,
      timezone: Meetup::DEFAULT_TIMEZONE,
      capacity: 50,
      status: :published
    )

    assert second.save!
    assert_equal "2026-06-14-2", second.slug
  end

  test "regenerates slug when starts_at date changes" do
    meetup = meetups(:open_meetup)
    new_starts_at = meetup.starts_at + 3.days
    meetup.starts_at = new_starts_at
    meetup.ends_at = new_starts_at.change(hour: meetup.ends_at.hour)
    meetup.valid?

    expected_prefix = new_starts_at.in_time_zone(meetup.time_zone).to_date.strftime("%Y-%m-%d")
    assert_match /\A#{expected_prefix}-\d+\z/, meetup.slug
  end

  private

  def with_env(vars)
    original = vars.keys.index_with { |key| ENV[key] }
    vars.each { |key, value| ENV[key] = value }
    yield
  ensure
    original.each do |key, value|
      if value.nil?
        ENV.delete(key)
      else
        ENV[key] = value
      end
    end
  end
end