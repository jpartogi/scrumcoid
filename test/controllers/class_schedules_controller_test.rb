require "test_helper"

class ClassSchedulesControllerTest < ActionDispatch::IntegrationTest
  test "displays schedule price in euro for EU visitors" do
    get class_schedules_path, headers: { "CF-IPCountry" => "DE" }

    assert_response :success
    assert_match "EUR 1195.00", response.body
  end

  test "falls back to usd schedule price when visitor currency is unavailable" do
    get class_schedules_path, headers: { "CF-IPCountry" => "JP" }

    assert_response :success
    assert_match "USD 1295.00", response.body
  end

  test "register form uses normal browser navigation for stripe redirect" do
    get class_schedule_path(class_schedules(:open_online))

    assert_response :success
    assert_select "form[data-turbo='false'][action='#{class_schedule_enrollment_path(class_schedules(:open_online))}']"
  end

  test "displays payment success flash after returning from stripe" do
    get class_schedule_path(class_schedules(:open_online)), params: { checkout: "success" }

    assert_response :success
    assert_select "p", text: /Payment received/
  end
end
