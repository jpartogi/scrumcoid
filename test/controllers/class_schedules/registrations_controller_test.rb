require "test_helper"

class ClassSchedules::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @schedule = class_schedules(:open_online)
  end

  test "should get new" do
    get new_class_schedule_registration_path(@schedule)
    assert_response :success
    assert_select "h1", text: @schedule.course.title
  end

  test "should create registration" do
    assert_difference("Registration.count") do
      post class_schedule_registrations_path(@schedule), params: {
        registration: {
          finance_name: "Finance Manager",
          finance_email: "finance@company.com",
          company_name: "Acme Corp",
          company_address: "123 Main St",
          company_phone: "123456789",
          enrollments_attributes: {
            "0" => {
              first_name: "John",
              last_name: "Doe",
              email: "john@doe.com"
            }
          }
        }
      }
    end

    assert_redirected_to class_schedule_path(@schedule)
  end
end
