require "test_helper"

class Admin::ClassSchedules::EnrollmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @schedule = class_schedules(:full_online)
    sign_in users(:admin)
  end

  test "new without count redirects to class schedule show" do
    get new_admin_class_schedule_enrollment_path(@schedule)
    assert_redirected_to admin_class_schedule_path(@schedule)
  end

  test "admin can view student entry form with batch size from show page" do
    get new_admin_class_schedule_enrollment_path(@schedule, count: 2)
    assert_response :success
    assert_select "h1", "Add 2 Registered Students"
    assert_select "input[name^='enrollments'][name$='[first_name]']", count: 2
    assert_select "input[name^='enrollments'][name$='[company_name]']", count: 2
  end

  test "batch size is capped at maximum" do
    get new_admin_class_schedule_enrollment_path(@schedule, count: 99)
    assert_response :success
    assert_select "input[name^='enrollments'][name$='[first_name]']", count: Admin::ClassSchedules::EnrollmentsController::MAX_BATCH_SIZE
  end

  test "admin can add one student bypassing capacity limits" do
    assert_difference "Enrollment.count", 1 do
      post admin_class_schedule_enrollments_path(@schedule), params: {
        enrollments: {
          "0" => {
            first_name: "Manual",
            last_name: "Entry",
            email: "manual@example.com",
            country: "Australia",
            company_name: "Acme Corp"
          }
        }
      }
    end

    assert_redirected_to admin_class_schedule_path(@schedule)
    enrollment = Enrollment.order(:created_at).last
    assert_equal "Manual Entry", enrollment.full_name
    assert_equal "Australia", enrollment.country
    assert_equal "Acme Corp", enrollment.company_name
    assert_nil enrollment.registration_id
  end

  test "admin can add multiple students in one batch" do
    assert_difference "Enrollment.count", 2 do
      post admin_class_schedule_enrollments_path(@schedule), params: {
        enrollments: {
          "0" => {
            first_name: "Alice",
            last_name: "Smith",
            email: "alice@example.com"
          },
          "1" => {
            first_name: "Bob",
            last_name: "Jones",
            email: "bob@example.com",
            country: "Indonesia"
          }
        }
      }
    end

    assert_redirected_to admin_class_schedule_path(@schedule)
    assert_match "2 students added", flash[:notice]
  end

  test "batch create re-renders form when a student is invalid" do
    assert_no_difference "Enrollment.count" do
      post admin_class_schedule_enrollments_path(@schedule), params: {
        enrollments: {
          "0" => {
            first_name: "Alice",
            last_name: "Smith",
            email: "alice@example.com"
          },
          "1" => {
            first_name: "Bob",
            last_name: "Jones",
            email: ""
          }
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select "h1", "Add 2 Registered Students"
  end

  test "student cannot access admin add student form" do
    sign_in users(:student)

    get new_admin_class_schedule_enrollment_path(@schedule, count: 1)
    assert_redirected_to root_path
  end
end