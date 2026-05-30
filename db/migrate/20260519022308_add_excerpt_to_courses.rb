class AddExcerptToCourses < ActiveRecord::Migration[8.1]
  def change
    add_column :courses, :excerpt, :text, null: false, default: ""
    change_column_default :courses, :excerpt, nil
  end
end
