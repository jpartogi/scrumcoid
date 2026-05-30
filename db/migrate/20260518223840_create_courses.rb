class CreateCourses < ActiveRecord::Migration[8.1]
  def change
    create_table :courses do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.text :description, null: false
      t.text :learning_objectives, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :courses, :slug, unique: true
    add_index :courses, :status
  end
end
