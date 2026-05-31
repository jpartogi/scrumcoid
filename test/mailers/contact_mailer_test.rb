require "test_helper"

class ContactMailerTest < ActionMailer::TestCase
  test "notification with fallback when no admin contacts configured" do
    AdminContact.destroy_all
    contact_message = ContactMessage.create!(
      name: "Andi",
      email: "andi@example.com",
      company: "Andi Corp",
      subject: "Quotation Pelatihan Privat - Scrum.org AI Essentials",
      message: "Tolong kirim quotation."
    )

    mail = ContactMailer.notification(contact_message)

    assert_equal "Pesan Baru dari Kontak: #{contact_message.subject}", mail.subject
    assert_includes mail.to, "jessica.stella@scrum.co.id"
    assert_includes mail.from, "andi@example.com"
    assert_nil mail.cc
    assert_match "Andi", mail.body.encoded
    assert_match "andi@example.com", mail.body.encoded
    assert_match "Andi Corp", mail.body.encoded
    assert_match "Tolong kirim quotation", mail.body.encoded
  end

  test "notification sends to main admin contacts in TO and others in CC" do
    AdminContact.destroy_all
    main_admin = AdminContact.create!(email: "main@example.com", main: true)
    cc_admin = AdminContact.create!(email: "cc@example.com", main: false)

    contact_message = ContactMessage.create!(
      name: "Budi",
      email: "budi@example.com",
      company: "Budi Corp",
      subject: "Waiting List Pelatihan Publik - Lainnya",
      message: "Tolong info jadwal baru."
    )

    mail = ContactMailer.notification(contact_message)

    assert_includes mail.to, "main@example.com"
    assert_includes mail.from, "budi@example.com"
    assert_not_includes mail.to, "cc@example.com"
    
    assert_includes mail.cc, "cc@example.com"
    assert_not_includes mail.cc, "main@example.com"
    
    assert_match "Budi", mail.body.encoded
    assert_match "Tolong info jadwal baru", mail.body.encoded
  end
end
