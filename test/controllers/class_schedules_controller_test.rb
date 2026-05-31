require "test_helper"

class ClassSchedulesControllerTest < ActionDispatch::IntegrationTest
  test "displays schedule price in euro for EU visitors" do
    get class_schedules_path, headers: { "CF-IPCountry" => "DE" }

    assert_response :success
    assert_match "EUR 1,195", response.body
  end

  test "falls back to usd schedule price when visitor currency is unavailable" do
    get class_schedules_path, headers: { "CF-IPCountry" => "JP" }

    assert_response :success
    assert_match "USD 1,295", response.body
  end

  test "register link directs to new registration form" do
    get class_schedule_path(class_schedules(:open_online))

    assert_response :success
    assert_select "a[href='#{new_class_schedule_registration_path(class_schedules(:open_online))}']"
  end

  test "displays payment success flash after returning from stripe" do
    get class_schedule_path(class_schedules(:open_online)), params: { checkout: "success" }

    assert_response :success
    assert_select "p", text: /Payment received/
  end
end
