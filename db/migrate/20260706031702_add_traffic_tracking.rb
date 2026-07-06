class AddTrafficTracking < ActiveRecord::Migration[8.1]
  def change
    add_column :unique_visits, :country, :string

    create_table :traffic_page_views do |t|
      t.string :path, null: false
      t.string :fingerprint, null: false
      t.date :viewed_on, null: false
      t.timestamps
    end

    add_index :traffic_page_views, [:path, :fingerprint, :viewed_on],
              unique: true,
              name: "index_traffic_page_views_on_path_fingerprint_and_day"
    add_index :traffic_page_views, :viewed_on
    add_index :unique_visits, :country
  end
end