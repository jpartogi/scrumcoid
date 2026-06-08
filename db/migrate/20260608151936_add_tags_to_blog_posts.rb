class AddTagsToBlogPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :blog_posts, :tags, :text
  end
end
