class CreateResourceDownloadRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :resource_download_requests do |t|
      t.references :resource, null: false, foreign_key: true
      t.string :visitor_name, null: false
      t.string :visitor_email, null: false
      t.integer :job_title, null: false
      t.string :token, null: false
      t.datetime :email_sent_at

      t.timestamps
    end

    add_index :resource_download_requests, :token, unique: true
    add_index :resource_download_requests, :visitor_email
  end
end