class RemoveUniquenessFromEmails < ActiveRecord::Migration[8.1]
  def up
    # Remove unique index on registrations (finance_email, class_schedule_id)
    remove_index :registrations, name: "index_registrations_on_schedule_and_finance_email"
    add_index :registrations, [:class_schedule_id, :finance_email], name: "index_registrations_on_schedule_and_finance_email"

    # Remove unique index on enrollments (visitor_email, class_schedule_id)
    remove_index :enrollments, name: "index_enrollments_on_visitor_email_and_class_schedule_id"
    add_index :enrollments, [:visitor_email, :class_schedule_id], name: "index_enrollments_on_visitor_email_and_class_schedule_id"
  end

  def down
    remove_index :registrations, name: "index_registrations_on_schedule_and_finance_email"
    add_index :registrations, [:class_schedule_id, :finance_email], name: "index_registrations_on_schedule_and_finance_email", unique: true

    remove_index :enrollments, name: "index_enrollments_on_visitor_email_and_class_schedule_id"
    add_index :enrollments, [:visitor_email, :class_schedule_id], name: "index_enrollments_on_visitor_email_and_class_schedule_id", unique: true
  end
end
