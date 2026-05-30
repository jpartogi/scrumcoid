require "openssl"
require "json"

class StripeWebhookEvent
  SignatureError = Class.new(StandardError)

  def self.construct(payload, signature_header, secret:)
    new(payload, signature_header, secret).construct
  end

  def initialize(payload, signature_header, secret)
    @payload = payload
    @signature_header = signature_header.to_s
    @secret = secret
  end

  def construct
    raise SignatureError, "Stripe webhook secret is not configured." if secret.blank?
    raise SignatureError, "Stripe signature is missing." if signature_header.blank?

    verify_signature!
    JSON.parse(payload)
  end

  private

  attr_reader :payload, :signature_header, :secret

  def verify_signature!
    timestamp = signature_parts.fetch("t")
    signatures = signature_parts.fetch("v1")
    signed_payload = "#{timestamp}.#{payload}"
    expected = OpenSSL::HMAC.hexdigest("SHA256", secret, signed_payload)

    return if signatures.any? { |signature| ActiveSupport::SecurityUtils.secure_compare(signature, expected) }

    raise SignatureError, "Stripe signature verification failed."
  rescue KeyError
    raise SignatureError, "Stripe signature is malformed."
  end

  def signature_parts
    signature_header.split(",").each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |part, parts|
      key, value = part.split("=", 2)
      parts[key] << value
    end
  end
end
