require "test_helper"

class InvitationEmailRendererTest < ActiveSupport::TestCase
  setup do
    @enrollment = enrollments(:existing_registration)
    @enrollment.update!(user: nil, first_name: "Jane", last_name: "Student", email: "jane@student.com")
    @schedule = @enrollment.class_schedule
    @schedule.course.update!(invitation_email: "Halo {{full_name}}, kelas {{course_title}} pada {{class_date}} di {{class_schedule_url}}.")
  end

  test "renders course invitation template with placeholders" do
    body = InvitationEmailRenderer.render(@enrollment)

    assert_includes body, "Halo Jane Student"
    assert_includes body, @schedule.course.title
    assert_not_includes body, "{{full_name}}"
  end

  test "renders venue placeholders correctly" do
    venue = venues(:jakarta_santika)
    @schedule.update!(online: false, venue: venue)
    @schedule.course.update!(invitation_email: "Venue: {{venue_name}} di {{venue_address}}")

    body = InvitationEmailRenderer.render(@enrollment)
    assert_includes body, "Venue: Hotel Santika Slipi di Jl. Aipda KS Tubun No.7, Jakarta Pusat 10260"
  end
end