class CreateAboutPages < ActiveRecord::Migration[8.1]
  def change
    create_table :about_pages do |t|
      t.string :title, null: false
      t.text :summary, null: false

      t.timestamps
    end
  end
end
