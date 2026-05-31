class RegistrationMailer < ApplicationMailer
  def quotation(registration)
    @registration = registration
    @course = registration.course
    pdf_content = QuotationPdf.generate(registration)

    # To: finance_email + main admin emails
    to_emails = [registration.finance_email]
    
    # CC: non-main admin emails
    cc_emails = []

    admin_emails = AdminEmail.all
    if admin_emails.exists?
      to_emails += admin_emails.where(main: true).pluck(:email)
      cc_emails += admin_emails.where(main: false).pluck(:email)
    else
      to_emails << "jessica.stella@scrum.co.id"
    end

    # Clean and unique emails
    to_emails = to_emails.map(&:strip).uniq.reject(&:empty?)
    cc_emails = cc_emails.map(&:strip).uniq.reject(&:empty?)

    attachments["quotation_#{registration.id}.pdf"] = {
      mime_type: "application/pdf",
      content: pdf_content
    }

    mail_options = {
      to: to_emails,
      subject: "Quotation for #{@course.title} - #{@registration.company_name}"
    }
    mail_options[:cc] = cc_emails if cc_emails.any?

    mail(mail_options)
  end
end

