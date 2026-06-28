class AddNameToMeetups < ActiveRecord::Migration[8.1]
  DEFAULT_NAME = "Scrum Meetup"

  def up
    add_column :meetups, :name, :string

    Meetup.update_all(name: DEFAULT_NAME)

    change_column_default :meetups, :name, from: nil, to: DEFAULT_NAME
    change_column_null :meetups, :name, false
  end

  def down
    remove_column :meetups, :name
  end
end