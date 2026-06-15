class AddInvitationTrackingToEnrollments < ActiveRecord::Migration[8.1]
  def change
    add_column :enrollments, :invitation_sent_at, :datetime
    add_column :enrollments, :invitation_opened_at, :datetime
    add_column :enrollments, :invitation_token, :string
    add_index :enrollments, :invitation_token, unique: true
  end
end
