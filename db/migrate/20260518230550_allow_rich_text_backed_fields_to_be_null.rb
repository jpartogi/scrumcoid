class AllowRichTextBackedFieldsToBeNull < ActiveRecord::Migration[8.1]
  def change
    change_column_null :courses, :description, true
    change_column_null :courses, :learning_objectives, true
    change_column_null :blog_posts, :body, true
  end
end
