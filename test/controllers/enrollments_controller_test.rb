require "test_helper"

class EnrollmentsControllerTest < ActionDispatch::IntegrationTest
  test "visitor is redirected to stripe checkout for open class schedule" do
    checkout_session = StripeCheckoutSession::Response.new(id: "cs_test_checkout", url: "https://checkout.stripe.com/pay/cs_test_checkout")

    original_create = StripeCheckoutSession.method(:create)
    StripeCheckoutSession.define_singleton_method(:create) { |**| checkout_session }

    begin
      assert_no_difference -> { Enrollment.count } do
        post class_schedule_enrollment_path(class_schedules(:open_online))
      end
    ensure
      StripeCheckoutSession.define_singleton_method(:create, original_create)
    end

    assert_response :see_other
    assert_redirected_to checkout_session.url
  end

  test "visitor cannot start checkout for closed class schedule" do
    assert_no_difference -> { Enrollment.count } do
      post class_schedule_enrollment_path(class_schedules(:closed_online))
    end

    assert_redirected_to class_schedule_path(class_schedules(:closed_online))
  end
end
