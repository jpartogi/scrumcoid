class CreateClassSchedules < ActiveRecord::Migration[8.1]
  def change
    create_table :class_schedules do |t|
      t.references :course, null: false, foreign_key: true
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.string :location, null: false
      t.boolean :online, null: false, default: true
      t.integer :price_cents, null: false
      t.string :currency, null: false
      t.datetime :registration_deadline, null: false
      t.integer :capacity, null: false, default: 20
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :class_schedules, :starts_at
    add_index :class_schedules, :status
  end
end
