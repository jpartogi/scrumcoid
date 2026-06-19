class CreateResources < ActiveRecord::Migration[8.1]
  def change
    create_table :resources do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.text :meta_description
      t.string :meta_keywords
      t.text :tags
      t.integer :page_count
      t.decimal :price, precision: 12, scale: 2, default: 0, null: false
      t.string :currency, default: "IDR", null: false
      t.integer :status, default: 0, null: false
      t.datetime :published_at

      t.timestamps
    end

    add_index :resources, :slug, unique: true
    add_index :resources, [:status, :published_at]
  end
end