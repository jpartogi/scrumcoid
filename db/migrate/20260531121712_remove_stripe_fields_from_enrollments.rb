class RemoveStripeFieldsFromEnrollments < ActiveRecord::Migration[8.1]
  def change
    remove_column :enrollments, :stripe_checkout_session_id, :string
    remove_column :enrollments, :stripe_payment_intent_id, :string
  end
end
