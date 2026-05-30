class RemoveLearningObjectivesFromCourses < ActiveRecord::Migration[8.1]
  def up
    execute "DELETE FROM action_text_rich_texts WHERE record_type = 'Course' AND name = 'learning_objectives'"
    remove_column :courses, :learning_objectives, :text
  end

  def down
    add_column :courses, :learning_objectives, :text
  end
end
