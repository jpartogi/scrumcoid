class RegistrationMailer < ApplicationMailer
  def quotation(registration, pdf_content)
    @registration = registration
    @course = registration.course

    # Send to finance + admin email
    recipients = [registration.finance_email]

    # TODO: Replace with actual admin email from settings
    admin_email = "admin@scrumcoid.com" 
    recipients << admin_email unless recipients.include?(admin_email)

    attachments["quotation_#{registration.id}.pdf"] = {
      mime_type: "application/pdf",
      content: pdf_content
    }

    mail(
      to: recipients,
      subject: "Quotation for #{@course.title} - #{@registration.company_name}"
    )
  end

end

