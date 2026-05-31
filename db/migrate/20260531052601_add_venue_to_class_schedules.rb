class AddVenueToClassSchedules < ActiveRecord::Migration[8.1]
  def change
    # nullable — online classes don't need a venue
    add_reference :class_schedules, :venue, null: true, foreign_key: true

    # remove the old flat columns
    remove_column :class_schedules, :venue_name, :string
    remove_column :class_schedules, :venue_address, :string
  end
end
