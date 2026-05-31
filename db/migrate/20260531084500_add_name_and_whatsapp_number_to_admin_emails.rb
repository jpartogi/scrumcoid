class AddNameAndWhatsappNumberToAdminEmails < ActiveRecord::Migration[8.1]
  def change
    add_column :admin_emails, :name, :string
    add_column :admin_emails, :whatsapp_number, :string
  end
end
