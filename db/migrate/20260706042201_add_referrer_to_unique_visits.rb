class AddReferrerToUniqueVisits < ActiveRecord::Migration[8.1]
  def change
    add_column :unique_visits, :referrer, :string
  end
end
