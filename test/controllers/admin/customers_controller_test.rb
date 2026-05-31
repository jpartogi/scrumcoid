require "test_helper"

class Admin::CustomersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @customer = Customer.create!(
      company_name: "Original Company Ltd",
      company_phone: "+62 21 9876 5432",
      company_address: "123 Business Parkway, Jakarta",
      finance_name: "Original Finance Contact",
      finance_email: "billing@originalcompany.com"
    )
    @registration = registrations(:one)
    @registration.update!(customer: @customer)
    @enrollment = enrollments(:existing_registration)
    @enrollment.update!(registration: @registration)
  end

  test "guest cannot access customers index" do
    get admin_customers_path
    assert_redirected_to new_user_session_path
  end

  test "admin can get customers index" do
    sign_in @admin
    get admin_customers_path
    assert_response :success
    assert_select "h1", "CRM / Customer Management"
    assert_select "td", text: /Original Company Ltd/
  end

  test "admin can search customers by company name" do
    sign_in @admin
    
    # Create another customer
    Customer.create!(
      company_name: "Other Company Corp",
      finance_name: "Other Finance",
      finance_email: "other@example.com"
    )

    get admin_customers_path, params: { query: "Original" }
    assert_response :success
    assert_select "td", text: /Original Company Ltd/
    assert_select "td", text: /Other Company Corp/, count: 0
  end

  test "admin can search customers by contact email" do
    sign_in @admin

    get admin_customers_path, params: { query: "billing@originalcompany.com" }
    assert_response :success
    assert_select "td", text: /Original Company Ltd/
  end

  test "admin can view customer details" do
    sign_in @admin
    get admin_customer_path(@customer)
    assert_response :success
    assert_select "h1", text: /Original Company Ltd/
    assert_select "dd", text: /Original Finance Contact/
    assert_select "dd", text: /billing@originalcompany.com/
  end

  test "admin can get customer edit page" do
    sign_in @admin
    get edit_admin_customer_path(@customer)
    assert_response :success
    assert_select "h1", "Edit Customer Profile"
  end

  test "admin can update customer profile" do
    sign_in @admin
    patch admin_customer_path(@customer), params: {
      customer: {
        company_name: "Updated Company Ltd",
        company_phone: "+62 812 3456 7890",
        company_address: "456 Corporate Towers, Jakarta",
        finance_name: "Updated Finance Name",
        finance_email: "finance@updatedcompany.com"
      }
    }
    assert_redirected_to admin_customer_path(@customer)
    
    @customer.reload
    assert_equal "Updated Company Ltd", @customer.company_name
    assert_equal "+62 812 3456 7890", @customer.company_phone
    assert_equal "456 Corporate Towers, Jakarta", @customer.company_address
    assert_equal "Updated Finance Name", @customer.finance_name
    assert_equal "finance@updatedcompany.com", @customer.finance_email
  end

  test "admin cannot update customer with invalid attributes" do
    sign_in @admin
    patch admin_customer_path(@customer), params: {
      customer: {
        company_name: "",
        finance_email: "invalid-email-format"
      }
    }
    assert_response :unprocessable_entity
    assert_select "div", text: /can't be blank/
  end

  test "admin can delete customer profile" do
    sign_in @admin
    assert_difference -> { Customer.count }, -1 do
      delete admin_customer_path(@customer)
    end
    assert_redirected_to admin_customers_path
  end
end
