class CreateRegistrations < ActiveRecord::Migration[8.1]
  def change
    create_table :registrations do |t|
      t.references :class_schedule, null: false, foreign_key: true
      t.string :finance_name, null: false
      t.string :finance_email, null: false
      t.string :company_name, null: false
      t.text :company_address
      t.string :company_phone

      t.integer :status, default: 0, null: false
      t.string :quotation_pdf_url
      t.datetime :quotation_sent_at

      t.timestamps
    end

    add_index :registrations, [:class_schedule_id, :finance_email], unique: true, name: "index_registrations_on_schedule_and_finance_email"

    add_reference :enrollments, :registration, foreign_key: true, index: true
  end
end
