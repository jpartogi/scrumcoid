class CreateMeetupRegistrations < ActiveRecord::Migration[8.1]
  def change
    create_table :meetup_registrations do |t|
      t.references :meetup, null: false, foreign_key: true
      t.string :visitor_name, null: false
      t.string :visitor_email, null: false
      t.integer :status, null: false, default: 0
      t.datetime :confirmation_email_sent_at
      t.datetime :follow_up_email_sent_at

      t.timestamps
    end

    add_index :meetup_registrations, [:visitor_email, :meetup_id], unique: true
    add_index :meetup_registrations, :follow_up_email_sent_at
  end
end