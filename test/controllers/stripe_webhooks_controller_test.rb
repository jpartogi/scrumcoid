require "test_helper"
require "openssl"

class StripeWebhooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    ActionMailer::Base.deliveries.clear
    Rails.application.config.x.stripe.webhook_secret = "whsec_test"
  end

  test "checkout session completed creates pending visitor enrollment and devise invitation email" do
    payload = stripe_event_payload(
      id: "cs_test_paid",
      class_schedule: class_schedules(:open_online),
      email: "buyer@example.com",
      full_name: "Buyer Person"
    )

    original_construct = StripeWebhookEvent.method(:construct)
    StripeWebhookEvent.define_singleton_method(:construct) { |*, **| JSON.parse(payload) }

    begin
      assert_difference -> { User.count }, 1 do
        assert_difference -> { Enrollment.active.count }, 1 do
          post stripe_webhook_path, params: payload, headers: stripe_headers(payload).merge("CONTENT_TYPE" => "application/json")
        end
      end
    ensure
      StripeWebhookEvent.define_singleton_method(:construct, original_construct)
    end

    assert_response :success
    user = User.find_by!(email: "buyer@example.com")
    enrollment = Enrollment.find_by!(stripe_checkout_session_id: "cs_test_paid")
    assert_nil enrollment.user
    assert_equal class_schedules(:open_online), enrollment.class_schedule
    assert_equal "buyer@example.com", enrollment.visitor_email
    assert_equal "Buyer Person", enrollment.visitor_name
    assert_equal "Buyer Person", user.name
    assert_equal "cs_test_paid", enrollment.stripe_checkout_session_id
    assert_equal "PI_TEST", enrollment.stripe_payment_intent_id
    assert_equal 129_500, enrollment.amount_paid_cents
    assert_equal "USD", enrollment.currency
    assert_equal 1, ActionMailer::Base.deliveries.count
    assert_match "Reset password instructions", ActionMailer::Base.deliveries.last.subject
  end

  test "student claims paid enrollment after setting password from devise email" do
    payload = stripe_event_payload(
      id: "cs_test_claim",
      class_schedule: class_schedules(:open_online),
      email: "claim@example.com",
      full_name: "Claim Person"
    )

    original_construct = StripeWebhookEvent.method(:construct)
    StripeWebhookEvent.define_singleton_method(:construct) { |*, **| JSON.parse(payload) }

    begin
      post stripe_webhook_path, params: payload, headers: stripe_headers(payload).merge("CONTENT_TYPE" => "application/json")
    ensure
      StripeWebhookEvent.define_singleton_method(:construct, original_construct)
    end

    user = User.find_by!(email: "claim@example.com")
    enrollment = Enrollment.find_by!(stripe_checkout_session_id: "cs_test_claim")
    assert_nil enrollment.user

    user.reset_password("new-password123", "new-password123")

    assert_equal user, enrollment.reload.user
  end

  test "checkout session completed for existing user associates enrollment immediately and does not send email" do
    existing_user = User.create!(
      email: "existing@example.com",
      name: "Existing Person",
      password: "password123",
      role: :student
    )

    payload = stripe_event_payload(
      id: "cs_test_existing",
      class_schedule: class_schedules(:open_online),
      email: "existing@example.com",
      full_name: "Existing Person"
    )

    original_construct = StripeWebhookEvent.method(:construct)
    StripeWebhookEvent.define_singleton_method(:construct) { |*, **| JSON.parse(payload) }

    begin
      assert_no_difference -> { User.count } do
        assert_difference -> { Enrollment.active.count }, 1 do
          post stripe_webhook_path, params: payload, headers: stripe_headers(payload).merge("CONTENT_TYPE" => "application/json")
        end
      end
    ensure
      StripeWebhookEvent.define_singleton_method(:construct, original_construct)
    end

    assert_response :success
    enrollment = Enrollment.find_by!(stripe_checkout_session_id: "cs_test_existing")
    assert_equal existing_user, enrollment.user
    assert_equal "existing@example.com", enrollment.visitor_email
    assert_equal "Existing Person", enrollment.visitor_name
    assert_equal 0, ActionMailer::Base.deliveries.count
  end

  test "rejects invalid stripe signature" do
    payload = stripe_event_payload(
      id: "cs_test_paid",
      class_schedule: class_schedules(:open_online),
      email: "buyer@example.com",
      full_name: "Buyer Person"
    )

    post stripe_webhook_path, params: payload, headers: { "Stripe-Signature" => "t=1,v1=bad", "CONTENT_TYPE" => "application/json" }

    assert_response :bad_request
  end

  private

  def stripe_event_payload(id:, class_schedule:, email:, full_name:)
    {
      id: "evt_test",
      type: "checkout.session.completed",
      data: {
        object: {
          id: id,
          payment_status: "paid",
          payment_intent: "PI_TEST",
          amount_total: 129_500,
          currency: "usd",
          metadata: {
            class_schedule_id: class_schedule.id.to_s
          },
          custom_fields: [
            {
              key: "full_name",
              text: {
                value: full_name
              }
            }
          ],
          customer_details: {
            email: email
          }
        }
      }
    }.to_json
  end

  def stripe_headers(payload)
    timestamp = Time.current.to_i
    signature = OpenSSL::HMAC.hexdigest("SHA256", Rails.application.config.x.stripe.webhook_secret, "#{timestamp}.#{payload}")

    { "Stripe-Signature" => "t=#{timestamp},v1=#{signature}" }
  end
end
