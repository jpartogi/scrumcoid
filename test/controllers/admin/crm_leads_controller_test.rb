require "test_helper"

class Admin::CrmLeadsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
  end

  test "guest cannot access leads index" do
    get admin_leads_path
    assert_redirected_to new_user_session_path
  end

  test "admin can get leads index" do
    sign_in @admin
    get admin_leads_path

    assert_response :success
    assert_select "h1", "CRM / Lead Management"
    assert_select "a[href=?]", admin_leads_path, text: /Leads/
    assert_select "td", text: /Budi Santoso/
    assert_select "td", text: /budi@example.com/
    assert_select "td", text: /Agile Glossary/
    assert_select "td", text: /Scrum Meetup/
    assert_select "td", text: /Siti Rahayu/
    assert_select "td", text: /siti@example.com/
  end

  test "admin can search leads by email" do
    sign_in @admin
    get admin_leads_path, params: { query: "budi@example.com" }

    assert_response :success
    assert_select "td", text: /Budi Santoso/
    assert_select "td", text: /siti@example.com/, count: 0
  end

  test "customers index includes CRM tabs linking to leads" do
    sign_in @admin
    get admin_customers_path

    assert_response :success
    assert_select "a[href=?]", admin_leads_path, text: /Leads/
  end

  test "students index includes CRM tabs linking to leads" do
    sign_in @admin
    get admin_students_path

    assert_response :success
    assert_select "a[href=?]", admin_leads_path, text: /Leads/
  end
end