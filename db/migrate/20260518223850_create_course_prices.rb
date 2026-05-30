class CreateCoursePrices < ActiveRecord::Migration[8.1]
  def change
    create_table :course_prices do |t|
      t.references :course, null: false, foreign_key: true
      t.integer :amount_cents, null: false
      t.string :currency, null: false
      t.string :label, null: false, default: "Standard"

      t.timestamps
    end

    add_index :course_prices, [:course_id, :currency, :label], unique: true
  end
end
