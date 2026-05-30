class AddTimezoneToClassSchedules < ActiveRecord::Migration[8.1]
  def change
    add_column :class_schedules, :timezone, :string, null: false, default: "Australia/Brisbane"
  end
end
