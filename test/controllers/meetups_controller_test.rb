require "test_helper"

class MeetupsControllerTest < ActionDispatch::IntegrationTest
  test "index lists upcoming published meetups" do
    get meetups_path

    assert_response :success
    assert_select "h1", text: "Meetup Scrum, Agile dan Manajemen Produk"
    assert_match meetups(:open_meetup).excerpt, response.body
    assert_match meetups(:upcoming_closed_registration_meetup).excerpt, response.body
    assert_no_match meetups(:draft_meetup).excerpt, response.body
    assert_no_match meetups(:ended_meetup).excerpt, response.body
    assert_match "Live Online", response.body
    assert_match meetups(:open_meetup).name, response.body
    assert_match "Batas pendaftaran:", response.body
    assert_match meetups(:open_meetup).registration_deadline.in_time_zone(meetups(:open_meetup).time_zone).strftime("%-d %b %Y"), response.body
  end

  test "index shows closed registration badge for upcoming meetups with closed registration" do
    get meetups_path

    assert_response :success
    assert_match "Pendaftaran Ditutup", response.body
    assert_match meetups(:upcoming_closed_registration_meetup).excerpt, response.body
    assert_no_match new_meetup_registration_path(meetups(:upcoming_closed_registration_meetup)), response.body
  end

  test "index omits online pill when meetup is not online" do
    meetups(:open_meetup).update!(online: false)

    get meetups_path

    assert_response :success
    assert_no_match "Live Online", response.body
  end

  test "show displays published meetup" do
    meetup = meetups(:open_meetup)
    get meetup_path(meetup)

    assert_response :success
    assert_match meetup.name, response.body
    assert_match meetup.slug, response.body
    assert_match meetup.excerpt, response.body
    assert_match "Live Online", response.body
  end

  test "show omits online pill when meetup is not online" do
    meetup = meetups(:open_meetup)
    meetup.update!(online: false)

    get meetup_path(meetup)

    assert_response :success
    assert_no_match "Live Online", response.body
  end
end