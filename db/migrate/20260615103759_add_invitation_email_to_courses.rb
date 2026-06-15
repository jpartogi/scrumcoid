class AddInvitationEmailToCourses < ActiveRecord::Migration[8.1]
  def change
    add_column :courses, :invitation_email, :text
  end
end
