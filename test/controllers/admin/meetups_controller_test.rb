require "test_helper"

class Admin::MeetupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @meetup = meetups(:open_meetup)
    sign_in @admin
  end

  test "index requires admin" do
    sign_out @admin
    get admin_meetups_path

    assert_redirected_to new_user_session_path
  end

  test "index shows only upcoming meetups by default" do
    past_meetup = meetups(:ended_meetup)

    get admin_meetups_path

    assert_response :success
    assert_match @meetup.slug, response.body
    assert_no_match past_meetup.slug, response.body
    assert_select "a[href=?]", admin_meetups_path(past: 1), text: /Past Meetups/
  end

  test "index with past param shows only past meetups" do
    past_meetup = meetups(:ended_meetup)

    get admin_meetups_path(past: 1)

    assert_response :success
    assert_select "h1", text: "Past Meetups"
    assert_match past_meetup.slug, response.body
    assert_no_match @meetup.slug, response.body
    assert_select "a[href=?]", admin_meetups_path, text: /Upcoming Meetups/
  end

  test "show displays meetup details" do
    get admin_meetup_path(@meetup)

    assert_response :success
    assert_match @meetup.slug, response.body
  end

  test "new meetup form" do
    get new_admin_meetup_path

    assert_response :success
    assert_select "h1", text: "New Meetup"
    assert_select "input[name='meetup[name]'][value=?]", Meetup::DEFAULT_NAME
    assert_no_match /name="meetup\[title\]"/, response.body
  end

  test "edit meetup form" do
    get edit_admin_meetup_path(@meetup)

    assert_response :success
    assert_select "h1", text: "Edit Meetup"
    assert_match @meetup.slug, response.body
  end

  test "create meetup generates date-based slug" do
    time_zone = Time.find_zone!(Meetup::DEFAULT_TIMEZONE)
    starts_at = time_zone.local(2026, 6, 14, 19, 0, 0)
    ends_at = starts_at.change(hour: 21, min: 0)

    assert_difference("Meetup.count") do
      post admin_meetups_path, params: {
        meetup: {
          excerpt: "Monthly community session for agile leaders.",
          description: "Join us to discuss agile leadership practices.",
          starts_at: starts_at.strftime("%Y-%m-%dT%H:%M"),
          ends_at: ends_at.strftime("%Y-%m-%dT%H:%M"),
          registration_deadline: (starts_at - 1.day).strftime("%Y-%m-%dT%H:%M"),
          timezone: Meetup::DEFAULT_TIMEZONE,
          join_link: "https://zoom.us/j/111222333",
          paypal_donation_url: "https://www.paypal.com/donate/?hosted_button_id=ABC",
          capacity: 80,
          status: "published",
          online: true
        }
      }
    end

    meetup = Meetup.order(:created_at).last
    assert_equal Meetup::DEFAULT_NAME, meetup.name
    assert_equal "scrum-meetup-2026-06-14", meetup.slug
    assert meetup.online?
    assert_redirected_to admin_meetup_path(meetup)
  end

  test "update meetup" do
    tz = @meetup.time_zone
    format_time = ->(value) { value.in_time_zone(tz).strftime("%Y-%m-%dT%H:%M") }

    patch admin_meetup_path(@meetup), params: {
      meetup: {
        excerpt: "Updated excerpt for the meetup.",
        description: @meetup.description.to_s,
        starts_at: format_time.call(@meetup.starts_at),
        ends_at: format_time.call(@meetup.ends_at),
        registration_deadline: format_time.call(@meetup.registration_deadline),
        timezone: @meetup.timezone,
        capacity: @meetup.capacity,
        status: @meetup.status
      }
    }

    assert_redirected_to admin_meetup_path(@meetup)
    assert_equal "Updated excerpt for the meetup.", @meetup.reload.excerpt
  end

  test "sidebar includes meetups link" do
    get admin_meetups_path

    assert_response :success
    assert_select "a[href=?]", admin_meetups_path, text: /Meetups/
  end
end