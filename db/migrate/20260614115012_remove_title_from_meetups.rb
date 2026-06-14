class RemoveTitleFromMeetups < ActiveRecord::Migration[8.1]
  def change
    remove_column :meetups, :title, :string
  end
end
