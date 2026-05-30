class StripeWebhooksController < ActionController::API
  def create
    event = StripeWebhookEvent.construct(
      request.raw_post,
      request.headers["Stripe-Signature"],
      secret: Rails.application.config.x.stripe.webhook_secret
    )

    PaidEnrollmentFulfillment.call(event.fetch("data").fetch("object")) if event["type"] == "checkout.session.completed"

    head :ok
  rescue StripeWebhookEvent::SignatureError
    head :bad_request
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound, PaidEnrollmentFulfillment::FulfillmentError => error
    Rails.logger.error("Stripe enrollment fulfillment failed: #{error.class}: #{error.message}")
    head :unprocessable_entity
  end
end
