require "test_helper"

class AdminEmailTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    admin_email = AdminEmail.new(email: "admin@example.com", main: true)
    assert admin_email.valid?
  end

  test "should require email" do
    admin_email = AdminEmail.new(email: nil, main: true)
    assert_not admin_email.valid?
    assert_includes admin_email.errors[:email], "can't be blank"
  end

  test "should enforce uniqueness of email case-insensitively" do
    AdminEmail.create!(email: "admin@example.com", main: false)
    duplicate = AdminEmail.new(email: "ADMIN@example.com", main: true)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end

  test "should reject invalid email formats" do
    invalid_emails = %w[admin admin@ admin@example admin.com]
    invalid_emails.each do |invalid|
      admin_email = AdminEmail.new(email: invalid)
      assert_not admin_email.valid?, "#{invalid} should not be valid"
    end
  end
end
