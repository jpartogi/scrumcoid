class CreateMeetups < ActiveRecord::Migration[8.1]
  def change
    create_table :meetups do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.text :excerpt, null: false
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.string :timezone, null: false, default: "Asia/Jakarta"
      t.string :join_link
      t.string :paypal_donation_url
      t.integer :capacity, null: false, default: 100
      t.datetime :registration_deadline, null: false
      t.integer :status, null: false, default: 0
      t.string :meta_keywords

      t.timestamps
    end

    add_index :meetups, :slug, unique: true
    add_index :meetups, :starts_at
    add_index :meetups, :status
  end
end