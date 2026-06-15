class MigrateInvitationEmailToRichText < ActiveRecord::Migration[8.1]
  class MigrationCourse < ApplicationRecord
    self.table_name = "courses"
  end

  def up
    MigrationCourse.reset_column_information
    MigrationCourse.where.not(invitation_email: [nil, ""]).find_each do |course|
      ActionText::RichText.create!(
        record_type: "Course",
        record_id: course.id,
        name: "invitation_email",
        body: course.invitation_email
      )
    end

    remove_column :courses, :invitation_email
  end

  def down
    add_column :courses, :invitation_email, :text

    ActionText::RichText.where(record_type: "Course", name: "invitation_email").find_each do |rich_text|
      MigrationCourse.where(id: rich_text.record_id).update_all(invitation_email: rich_text.body.to_plain_text)
      rich_text.destroy!
    end
  end
end