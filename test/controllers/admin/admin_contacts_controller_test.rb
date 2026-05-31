require "test_helper"

class Admin::AdminContactsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @student = users(:student)
    @admin_contact = AdminContact.create!(email: "notify@example.com", main: true)
  end

  test "should require admin access for index" do
    sign_in @student
    get admin_admin_contacts_path
    assert_redirected_to root_path
  end

  test "should get index when admin" do
    sign_in @admin
    get admin_admin_contacts_path
    assert_response :success
    assert_select "h1", "Manage Admin Contacts"
    assert_select "td", text: "notify@example.com"
  end

  test "should get new" do
    sign_in @admin
    get new_admin_admin_contact_path
    assert_response :success
  end

  test "should create admin_contact" do
    sign_in @admin
    assert_difference("AdminContact.count") do
      post admin_admin_contacts_path, params: { admin_contact: { email: "new_admin@example.com", main: false, name: "New Admin", whatsapp_number: "+62877" } }
    end
    assert_redirected_to admin_admin_contacts_path
    assert_equal "Admin contact was successfully created.", flash[:notice]
    created = AdminContact.order(:created_at).last
    assert_equal "New Admin", created.name
    assert_equal "+62877", created.whatsapp_number
  end

  test "should get edit" do
    sign_in @admin
    get edit_admin_admin_contact_path(@admin_contact)
    assert_response :success
  end

  test "should update admin_contact" do
    sign_in @admin
    patch admin_admin_contact_path(@admin_contact), params: { admin_contact: { email: "updated@example.com", main: false, name: "Updated Admin", whatsapp_number: "+62899" } }
    assert_redirected_to admin_admin_contacts_path
    assert_equal "Admin contact was successfully updated.", flash[:notice]
    @admin_contact.reload
    assert_equal "updated@example.com", @admin_contact.email
    assert_not @admin_contact.main
    assert_equal "Updated Admin", @admin_contact.name
    assert_equal "+62899", @admin_contact.whatsapp_number
  end

  test "should destroy admin_contact" do
    sign_in @admin
    assert_difference("AdminContact.count", -1) do
      delete admin_admin_contact_path(@admin_contact)
    end
    assert_redirected_to admin_admin_contacts_path
    assert_equal "Admin contact was successfully deleted.", flash[:notice]
  end
end
