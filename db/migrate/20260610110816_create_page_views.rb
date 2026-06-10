class CreatePageViews < ActiveRecord::Migration[8.1]
  def change
    create_table :page_views do |t|
      t.references :viewable, polymorphic: true, null: false
      t.string :fingerprint, null: false
      t.date :viewed_on, null: false

      t.timestamps
    end

    add_index :page_views, [:viewable_type, :viewable_id, :fingerprint, :viewed_on],
      unique: true, name: "index_page_views_on_viewable_fingerprint_and_day"
    add_index :page_views, :viewed_on
  end
end