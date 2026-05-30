class AllowPendingVisitorEnrollments < ActiveRecord::Migration[8.1]
  def change
    change_column_null :enrollments, :user_id, true
    add_column :enrollments, :visitor_email, :string
    add_column :enrollments, :visitor_name, :string

    add_index :enrollments, [ :visitor_email, :class_schedule_id ], unique: true
  end
end
