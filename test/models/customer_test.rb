require "test_helper"

class CustomerTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    customer = Customer.new(
      finance_name: "Liana Ekawati",
      finance_email: "liana@example.com",
      company_name: "Scrumcoid Corp"
    )
    assert customer.valid?
  end

  test "should require finance_email, finance_name, and company_name" do
    customer = Customer.new
    assert_not customer.valid?
    assert_includes customer.errors[:finance_email], "can't be blank"
    assert_includes customer.errors[:finance_name], "can't be blank"
    assert_includes customer.errors[:company_name], "can't be blank"
  end

  test "should enforce uniqueness of finance_email case-insensitively" do
    Customer.create!(
      finance_name: "Liana",
      finance_email: "liana@example.com",
      company_name: "Scrumcoid"
    )
    duplicate = Customer.new(
      finance_name: "Liana Duplicate",
      finance_email: "LIANA@example.com",
      company_name: "Scrumcoid Corp"
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:finance_email], "has already been taken"
  end
end
