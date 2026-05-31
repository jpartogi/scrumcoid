class AddMetaKeywordsToCoursesAndBlogPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :courses, :meta_keywords, :string
    add_column :blog_posts, :meta_keywords, :string
  end
end
