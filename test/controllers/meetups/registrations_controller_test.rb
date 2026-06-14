require "test_helper"

class Meetups::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @meetup = meetups(:open_meetup)
  end

  test "should get new" do
    get new_meetup_registration_path(@meetup)

    assert_response :success
    assert_match @meetup.slug, response.body
  end

  test "should create registration and enqueue confirmation email" do
    assert_difference("MeetupRegistration.count") do
      assert_enqueued_emails 1 do
        post meetup_registrations_path(@meetup), params: {
          meetup_registration: {
            visitor_name: "Andi Wijaya",
            visitor_email: "andi@example.com"
          }
        }
      end
    end

    assert_redirected_to meetup_path(@meetup)
    registration = MeetupRegistration.find_by(visitor_email: "andi@example.com")
    assert_not_nil registration.confirmation_email_sent_at
  end
end