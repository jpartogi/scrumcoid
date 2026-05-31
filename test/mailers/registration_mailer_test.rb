require "test_helper"

class RegistrationMailerTest < ActionMailer::TestCase
  test "quotation with fallback when no admin emails configured" do
    AdminEmail.destroy_all
    registration = registrations(:one)
    mail = RegistrationMailer.quotation(registration)
    
    assert_equal "Penawaran untuk #{registration.course.title} - #{registration.company_name}", mail.subject
    assert_includes mail.to, registration.finance_email
    assert_includes mail.to, "jessica.stella@scrum.co.id"
    assert_nil mail.cc
    assert_match "Terima kasih atas ketertarikan", mail.body.encoded
  end

  test "quotation sends to main admin emails in TO and others in CC" do
    AdminEmail.destroy_all
    main_admin = AdminEmail.create!(email: "main@example.com", main: true)
    cc_admin = AdminEmail.create!(email: "cc@example.com", main: false)

    registration = registrations(:one)
    mail = RegistrationMailer.quotation(registration)

    assert_includes mail.to, registration.finance_email
    assert_includes mail.to, "main@example.com"
    assert_not_includes mail.to, "cc@example.com"
    
    assert_includes mail.cc, "cc@example.com"
    assert_not_includes mail.cc, "main@example.com"
    assert_not_includes mail.cc, registration.finance_email
  end
end
