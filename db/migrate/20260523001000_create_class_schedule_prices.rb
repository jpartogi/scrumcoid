class CreateClassSchedulePrices < ActiveRecord::Migration[8.1]
  def up
    create_table :class_schedule_prices do |t|
      t.references :class_schedule, null: false, foreign_key: true
      t.float :amount, null: false
      t.string :currency, null: false

      t.timestamps
    end

    add_index :class_schedule_prices, [ :class_schedule_id, :currency ], unique: true

    execute <<~SQL.squish
      INSERT INTO class_schedule_prices (class_schedule_id, amount, currency, created_at, updated_at)
      SELECT id, price_cents / 100.0, currency, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM class_schedules
    SQL

    remove_column :class_schedules, :price_cents
    remove_column :class_schedules, :currency
  end

  def down
    add_column :class_schedules, :price_cents, :integer, null: false, default: 0
    add_column :class_schedules, :currency, :string, null: false, default: "USD"

    execute <<~SQL.squish
      UPDATE class_schedules
      SET price_cents = (
        SELECT ROUND(amount * 100)
        FROM class_schedule_prices
        WHERE class_schedule_prices.class_schedule_id = class_schedules.id
        ORDER BY CASE currency WHEN 'USD' THEN 0 ELSE 1 END, currency
        LIMIT 1
      ),
      currency = (
        SELECT currency
        FROM class_schedule_prices
        WHERE class_schedule_prices.class_schedule_id = class_schedules.id
        ORDER BY CASE currency WHEN 'USD' THEN 0 ELSE 1 END, currency
        LIMIT 1
      )
    SQL

    change_column_default :class_schedules, :price_cents, nil
    change_column_default :class_schedules, :currency, nil
    drop_table :class_schedule_prices
  end
end
