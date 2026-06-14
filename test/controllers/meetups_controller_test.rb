require "test_helper"

class MeetupsControllerTest < ActionDispatch::IntegrationTest
  test "index lists available meetups" do
    get meetups_path

    assert_response :success
    assert_select "h1", text: "Meetup Scrum & Agile"
    assert_match meetups(:open_meetup).excerpt, response.body
    assert_no_match meetups(:draft_meetup).excerpt, response.body
  end

  test "show displays published meetup" do
    meetup = meetups(:open_meetup)
    get meetup_path(meetup)

    assert_response :success
    assert_match meetup.slug, response.body
    assert_match meetup.excerpt, response.body
  end
end