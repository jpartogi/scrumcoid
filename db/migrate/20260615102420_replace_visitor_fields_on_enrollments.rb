class ReplaceVisitorFieldsOnEnrollments < ActiveRecord::Migration[8.1]
  class MigrationEnrollment < ApplicationRecord
    self.table_name = "enrollments"
  end

  def up
    add_column :enrollments, :first_name, :string
    add_column :enrollments, :last_name, :string
    add_column :enrollments, :email, :string
    add_column :enrollments, :country, :string

    MigrationEnrollment.reset_column_information
    MigrationEnrollment.find_each do |enrollment|
      visitor_name = enrollment.read_attribute(:visitor_name)
      next if visitor_name.blank?

      parts = visitor_name.strip.split(/\s+/, 2)
      enrollment.update_columns(
        first_name: parts[0],
        last_name: parts[1].to_s,
        email: enrollment.read_attribute(:visitor_email)
      )
    end

    remove_index :enrollments, name: "index_enrollments_on_visitor_email_and_class_schedule_id"
    remove_column :enrollments, :visitor_name
    remove_column :enrollments, :visitor_email
    add_index :enrollments, [:email, :class_schedule_id], name: "index_enrollments_on_email_and_class_schedule_id"
  end

  def down
    add_column :enrollments, :visitor_name, :string
    add_column :enrollments, :visitor_email, :string

    MigrationEnrollment.reset_column_information
    MigrationEnrollment.find_each do |enrollment|
      full_name = [enrollment.read_attribute(:first_name), enrollment.read_attribute(:last_name)].compact_blank.join(" ")
      next if full_name.blank?

      enrollment.update_columns(
        visitor_name: full_name,
        visitor_email: enrollment.read_attribute(:email)
      )
    end

    remove_index :enrollments, name: "index_enrollments_on_email_and_class_schedule_id"
    remove_column :enrollments, :first_name
    remove_column :enrollments, :last_name
    remove_column :enrollments, :email
    remove_column :enrollments, :country
    add_index :enrollments, [:visitor_email, :class_schedule_id], name: "index_enrollments_on_visitor_email_and_class_schedule_id"
  end
end