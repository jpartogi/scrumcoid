class AddOnlineToMeetups < ActiveRecord::Migration[8.1]
  def change
    add_column :meetups, :online, :boolean, default: false, null: false
  end
end
