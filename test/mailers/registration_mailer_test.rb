require "test_helper"

class RegistrationMailerTest < ActionMailer::TestCase
  test "quotation with fallback when no admin emails configured" do
    AdminContact.destroy_all
    registration = registrations(:one)
    mail = RegistrationMailer.quotation(registration)
    
    assert_equal "Penawaran untuk #{registration.course.title} - #{registration.company_name}", mail.subject
    assert_includes mail.to, registration.finance_email
    assert_includes mail.to, "jessica.stella@scrum.co.id"
    assert_nil mail.cc
    assert_match "Terima kasih atas ketertarikan", mail.body.encoded

    # Check default fallback signature and whatsapp number in email body
    assert_match "Jessica Stella", mail.body.encoded
    assert_match "+62 856 4342 8348", mail.body.encoded
  end

  test "quotation sends to main admin emails in TO and others in CC" do
    AdminContact.destroy_all
    main_admin = AdminContact.create!(email: "main@example.com", main: true, name: "Budi Santoso", whatsapp_number: "+62 888 8888 8888")
    cc_admin = AdminContact.create!(email: "cc@example.com", main: false)

    registration = registrations(:one)
    mail = RegistrationMailer.quotation(registration)

    assert_includes mail.to, registration.finance_email
    assert_includes mail.to, "main@example.com"
    assert_not_includes mail.to, "cc@example.com"
    
    assert_includes mail.cc, "cc@example.com"
    assert_not_includes mail.cc, "main@example.com"
    assert_not_includes mail.cc, registration.finance_email

    # Check dynamic signature and whatsapp number in email body
    assert_match "Budi Santoso", mail.body.encoded
    assert_match "+62 888 8888 8888", mail.body.encoded
  end
end
