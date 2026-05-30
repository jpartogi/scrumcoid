class PaidEnrollmentFulfillment
  FulfillmentError = Class.new(StandardError)

  def self.call(...)
    new.call(...)
  end

  def call(checkout_session)
    return unless checkout_session["payment_status"] == "paid"
    return if Enrollment.exists?(stripe_checkout_session_id: checkout_session.fetch("id"))

    class_schedule = ClassSchedule.find(checkout_session.dig("metadata", "class_schedule_id"))
    email = checkout_session.dig("customer_details", "email").presence || checkout_session["customer_email"].presence
    raise FulfillmentError, "Stripe checkout session does not include a customer email." if email.blank?

    full_name = full_name_from(checkout_session).presence || email.split("@").first
    user, new_user = find_or_create_student(email, full_name)
    enrollment = if new_user
      Enrollment.find_or_initialize_by(visitor_email: email.downcase, class_schedule: class_schedule)
    else
      Enrollment.find_by(user: user, class_schedule: class_schedule) ||
        Enrollment.find_or_initialize_by(visitor_email: email.downcase, class_schedule: class_schedule)
    end

    enrollment.assign_attributes(enrollment_attributes(checkout_session))
    enrollment.user = user unless new_user
    enrollment.status = :active
    enrollment.save!

    user.reload.send_reset_password_instructions if new_user
    enrollment
  end

  private

  def find_or_create_student(email, full_name)
    user = User.find_or_initialize_by(email: email.downcase)
    new_user = user.new_record?

    if new_user
      user.name = full_name
      user.password = SecureRandom.base58(32)
      user.role = :student
      user.save!
    end

    [ user, new_user ]
  end

  def enrollment_attributes(checkout_session)
    {
      stripe_checkout_session_id: checkout_session.fetch("id"),
      stripe_payment_intent_id: checkout_session["payment_intent"],
      paid_at: Time.current,
      amount_paid_cents: checkout_session["amount_total"],
      currency: checkout_session["currency"]&.upcase,
      visitor_email: (checkout_session.dig("customer_details", "email").presence || checkout_session["customer_email"]).downcase,
      visitor_name: full_name_from(checkout_session).presence || checkout_session.dig("customer_details", "email").to_s.split("@").first
    }
  end

  def full_name_from(checkout_session)
    checkout_session.fetch("custom_fields", []).find { |field| field["key"] == "full_name" }&.dig("text", "value").presence ||
      checkout_session.dig("customer_details", "name").presence
  end
end
