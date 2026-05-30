require "test_helper"

class StripeCheckoutSessionTest < ActiveSupport::TestCase
  test "requests full name custom field for checkout" do
    service = StripeCheckoutSession.new
    schedule = class_schedules(:open_online)
    price = schedule.price_for("USD")

    params = service.send(:session_params, schedule, price, "https://example.com/success", "https://example.com/cancel")

    assert_equal "full_name", params["custom_fields[0][key]"]
    assert_equal "custom", params["custom_fields[0][label][type]"]
    assert_equal "Full name", params["custom_fields[0][label][custom]"]
    assert_equal "text", params["custom_fields[0][type]"]
  end
end
