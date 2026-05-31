require "test_helper"

class AdminContactTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    admin_contact = AdminContact.new(email: "admin@example.com", main: true)
    assert admin_contact.valid?
  end

  test "should be valid with optional name and whatsapp_number" do
    admin_contact = AdminContact.new(email: "contact@example.com", main: false, name: "Admin Name", whatsapp_number: "+62812345")
    assert admin_contact.valid?
    assert admin_contact.save
    assert_equal "Admin Name", admin_contact.name
    assert_equal "+62812345", admin_contact.whatsapp_number
  end

  test "should require email" do
    admin_contact = AdminContact.new(email: nil, main: true)
    assert_not admin_contact.valid?
    assert_includes admin_contact.errors[:email], "can't be blank"
  end

  test "should enforce uniqueness of email case-insensitively" do
    AdminContact.create!(email: "admin@example.com", main: false)
    duplicate = AdminContact.new(email: "ADMIN@example.com", main: true)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end

  test "should reject invalid email formats" do
    invalid_emails = %w[admin admin@ admin@example admin.com]
    invalid_emails.each do |invalid|
      admin_contact = AdminContact.new(email: invalid)
      assert_not admin_contact.valid?, "#{invalid} should not be valid"
    end
  end
end
