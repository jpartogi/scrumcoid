class CreateUniqueVisits < ActiveRecord::Migration[8.1]
  def change
    create_table :unique_visits do |t|
      t.string :ip_hash, null: false
      t.date :visited_on, null: false

      t.timestamps
    end

    # Composite unique index ensures a visitor can only have one visit record per day
    add_index :unique_visits, [:ip_hash, :visited_on], unique: true
    # Index on visited_on optimizes dashboard statistics queries
    add_index :unique_visits, :visited_on
  end
end
