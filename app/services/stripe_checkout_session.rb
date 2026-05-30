require "net/http"
require "json"

class StripeCheckoutSession
  API_URI = URI("https://api.stripe.com/v1/checkout/sessions")

  ConfigurationError = Class.new(StandardError)
  CheckoutError = Class.new(StandardError)

  Response = Data.define(:id, :url)

  def self.create(...)
    new.create(...)
  end

  def create(class_schedule:, currency:, success_url:, cancel_url:)
    price = class_schedule.price_for(currency)
    raise CheckoutError, "No price is available for this class schedule." if price.blank?

    response = post_form(session_params(class_schedule, price, success_url, cancel_url))
    body = JSON.parse(response.body)

    raise CheckoutError, body.dig("error", "message").presence || "Stripe checkout session could not be created." unless response.is_a?(Net::HTTPSuccess)

    Response.new(id: body.fetch("id"), url: body.fetch("url"))
  rescue JSON::ParserError, KeyError, SocketError, SystemCallError, Net::OpenTimeout, Net::ReadTimeout => error
    raise CheckoutError, "Stripe checkout session could not be created: #{error.message}"
  end

  private

  def post_form(params)
    request = Net::HTTP::Post.new(API_URI)
    request.basic_auth(secret_key, "")
    request.set_form_data(params)

    Net::HTTP.start(API_URI.hostname, API_URI.port, use_ssl: true) do |http|
      http.request(request)
    end
  end

  def session_params(class_schedule, price, success_url, cancel_url)
    {
      "mode" => "payment",
      "success_url" => success_url,
      "cancel_url" => cancel_url,
      "line_items[0][quantity]" => "1",
      "line_items[0][price_data][currency]" => price.currency.downcase,
      "line_items[0][price_data][unit_amount]" => (price.amount.to_d * 100).round.to_i.to_s,
      "line_items[0][price_data][product_data][name]" => class_schedule.course.title,
      "custom_fields[0][key]" => "full_name",
      "custom_fields[0][label][type]" => "custom",
      "custom_fields[0][label][custom]" => "Full name",
      "custom_fields[0][type]" => "text",
      "metadata[class_schedule_id]" => class_schedule.id.to_s,
      "metadata[course_id]" => class_schedule.course_id.to_s
    }
  end

  def secret_key
    Rails.application.config.x.stripe.secret_key.presence ||
      raise(ConfigurationError, "STRIPE_SECRET_KEY is not configured.")
  end
end
