class RemoveClassSchedulePricesAndAddVenueToClassSchedules < ActiveRecord::Migration[8.1]
  def up
    drop_table :class_schedule_prices if table_exists?(:class_schedule_prices)
    add_column :class_schedules, :venue_name, :string
    add_column :class_schedules, :venue_address, :string
  end

  def down
    remove_column :class_schedules, :venue_address
    remove_column :class_schedules, :venue_name

    create_table :class_schedule_prices do |t|
      t.references :class_schedule, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :currency, null: false
      t.timestamps
    end
    add_index :class_schedule_prices, [:class_schedule_id, :currency], unique: true
  end
end
