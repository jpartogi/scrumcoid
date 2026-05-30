class RemoveLabelFromCoursePrices < ActiveRecord::Migration[8.1]
  def change
    remove_index :course_prices, column: [:course_id, :currency, :label]
    remove_column :course_prices, :label, :string
    add_index :course_prices, [:course_id, :currency], unique: true
  end
end
