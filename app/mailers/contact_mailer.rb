class ContactMailer < ApplicationMailer
  def notification(contact_message)
    @contact_message = contact_message

    # To: main admin emails
    to_emails = []
    
    # CC: non-main admin emails
    cc_emails = []

    admin_contacts = AdminContact.all
    if admin_contacts.exists?
      to_emails += admin_contacts.where(main: true).pluck(:email)
      cc_emails += admin_contacts.where(main: false).pluck(:email)
    else
      to_emails << "jessica.stella@scrum.co.id"
    end

    # Fallback to default if no main admin emails exist
    if to_emails.empty?
      to_emails << "jessica.stella@scrum.co.id"
    end

    to_emails = to_emails.map(&:strip).uniq.reject(&:empty?)
    cc_emails = cc_emails.map(&:strip).uniq.reject(&:empty?)

    mail_options = {
      from: @contact_message.email,
      to: to_emails,
      subject: "Pesan Baru dari Kontak: #{@contact_message.subject}"
    }
    mail_options[:cc] = cc_emails if cc_emails.any?

    mail(mail_options)
  end
end
