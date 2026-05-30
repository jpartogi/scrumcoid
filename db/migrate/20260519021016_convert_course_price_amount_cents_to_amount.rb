class ConvertCoursePriceAmountCentsToAmount < ActiveRecord::Migration[8.1]
  def up
    add_column :course_prices, :amount, :float, null: false, default: 0.0
    execute "UPDATE course_prices SET amount = amount_cents / 100.0"
    change_column_default :course_prices, :amount, nil
    remove_column :course_prices, :amount_cents
  end

  def down
    add_column :course_prices, :amount_cents, :integer, null: false, default: 0
    execute "UPDATE course_prices SET amount_cents = ROUND(amount * 100)"
    change_column_default :course_prices, :amount_cents, nil
    remove_column :course_prices, :amount
  end
end
