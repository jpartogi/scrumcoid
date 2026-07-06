require "test_helper"

class Admin::TrafficControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    UniqueVisit.destroy_all
    TrafficPageView.destroy_all
    sign_in @admin
  end

  test "show requires admin" do
    sign_out @admin
    get admin_traffic_path

    assert_redirected_to new_user_session_path
  end

  test "show displays traffic breakdown for admin" do
    brisbane = Time.find_zone("Australia/Brisbane")
    real_ua = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

    travel_to brisbane.local(2026, 6, 14, 10, 0, 0) do
      get root_path, headers: { "User-Agent" => real_ua, "CF-IPCountry" => "ID", "Referer" => "https://www.google.com/" }
      get courses_path, headers: { "User-Agent" => real_ua, "CF-IPCountry" => "ID", "Referer" => "https://www.google.com/" }
    end

    get admin_traffic_path

    assert_response :success
    assert_select "h1", text: "Traffic Breakdown"
    assert_select "h2", text: /Visitor Traffic/
    assert_select "h2", text: "Top Pages"
    assert_select "h2", text: "Visitors by Country"
    assert_select "h2", text: "Traffic Sources"
    assert_select "svg"
    assert_select "p", text: /Daily unique visits/
    assert_match "Home", response.body
    assert_match "Courses", response.body
    assert_match "Indonesia", response.body
    assert_match "Google Search", response.body
  end

  test "show supports period filter" do
    get admin_traffic_path(days: 7)

    assert_response :success
    assert_select "a[href=?]", admin_traffic_path(days: 7)
    assert_select "a[href=?]", admin_traffic_path(days: 30)
    assert_select "a[href=?]", admin_traffic_path(days: 90)
  end

  test "sidebar includes traffic link" do
    get admin_traffic_path

    assert_response :success
    assert_select "a[href=?]", admin_traffic_path, text: /Traffic/
  end
end