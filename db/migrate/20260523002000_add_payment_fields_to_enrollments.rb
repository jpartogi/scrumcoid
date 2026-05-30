class AddPaymentFieldsToEnrollments < ActiveRecord::Migration[8.1]
  def change
    add_column :enrollments, :stripe_checkout_session_id, :string
    add_column :enrollments, :stripe_payment_intent_id, :string
    add_column :enrollments, :paid_at, :datetime
    add_column :enrollments, :amount_paid_cents, :integer
    add_column :enrollments, :currency, :string

    add_index :enrollments, :stripe_checkout_session_id, unique: true
    add_index :enrollments, :stripe_payment_intent_id
  end
end
