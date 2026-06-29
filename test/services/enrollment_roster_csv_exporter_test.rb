require "test_helper"

class EnrollmentRosterCsvExporterTest < ActiveSupport::TestCase
  test "exports roster rows with headers" do
    schedule = class_schedules(:open_online)
    enrollment = enrollments(:existing_registration)
    enrollment.update!(
      company_name: "Acme Corp",
      country: "Indonesia",
      invitation_sent_at: Time.current
    )

    csv = EnrollmentRosterCsvExporter.new(schedule).to_csv
    rows = CSV.parse(csv)

    assert_equal EnrollmentRosterCsvExporter::HEADERS, rows.first
    student_row = rows.find { |row| row[1] == enrollment.attendee_email }
    assert_not_nil student_row
    assert_equal enrollment.attendee_name, student_row[0]
    assert_equal "Indonesia", student_row[2]
    assert_equal "Acme Corp", student_row[3]
    assert_equal "active", student_row[4]
    assert_equal "Sent", student_row[5]
  end

  test "filename includes course slug and schedule date" do
    schedule = class_schedules(:open_online)
    exporter = EnrollmentRosterCsvExporter.new(schedule)

    assert_equal "#{schedule.course.slug}-#{schedule.starts_at.strftime('%Y-%m-%d')}-roster.csv", exporter.filename
  end
end