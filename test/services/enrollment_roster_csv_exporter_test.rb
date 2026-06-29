require "test_helper"

class EnrollmentRosterCsvExporterTest < ActiveSupport::TestCase
  test "exports roster rows without headers" do
    schedule = class_schedules(:open_online)
    enrollment = enrollments(:existing_registration)
    enrollment.update!(
      country: "Indonesia"
    )

    csv = EnrollmentRosterCsvExporter.new(schedule).to_csv
    rows = CSV.parse(csv)

    student_row = rows.find { |row| row[2] == enrollment.attendee_email }
    assert_not_nil student_row
    assert_equal "Student", student_row[0]
    assert_equal "User", student_row[1]
    assert_equal "Indonesia", student_row[3]
    assert_equal 4, student_row.length
  end

  test "filename includes course slug and schedule date" do
    schedule = class_schedules(:open_online)
    exporter = EnrollmentRosterCsvExporter.new(schedule)

    assert_equal "#{schedule.course.slug}-#{schedule.starts_at.strftime('%Y-%m-%d')}-roster.csv", exporter.filename
  end
end