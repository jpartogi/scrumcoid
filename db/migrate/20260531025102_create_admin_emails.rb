class CreateAdminEmails < ActiveRecord::Migration[8.1]
  def change
    create_table :admin_emails do |t|
      t.string :email, null: false
      t.boolean :main, null: false, default: false

      t.timestamps
    end
    add_index :admin_emails, :email, unique: true
  end
end
