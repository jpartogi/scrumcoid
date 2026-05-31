class RenameAdminEmailsToAdminContacts < ActiveRecord::Migration[8.1]
  def change
    rename_table :admin_emails, :admin_contacts
  end
end
