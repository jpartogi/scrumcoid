require "test_helper"

class RegistrationMailerTest < ActionMailer::TestCase
  test "quotation" do
    registration = registrations(:one)
    pdf_content = "%PDF-1.4 mock pdf content"
    mail = RegistrationMailer.quotation(registration, pdf_content)
    assert_equal "Quotation for #{registration.course.title} - #{registration.company_name}", mail.subject
    assert_includes mail.to, registration.finance_email
    assert_match "Thank you for your interest", mail.body.encoded
  end
end
