require "csv"

class EnrollmentRosterCsvExporter
  HEADERS = [
    "Name",
    "Email",
    "Country",
    "Company",
    "Status",
    "Invitation",
    "Registered At"
  ].freeze

  def initialize(class_schedule)
    @class_schedule = class_schedule
  end

  def to_csv
    CSV.generate do |csv|
      csv << HEADERS
      enrollments.each do |enrollment|
        csv << row_for(enrollment)
      end
    end
  end

  def filename
    course_slug = @class_schedule.course.slug
    date = @class_schedule.starts_at.strftime("%Y-%m-%d")
    "#{course_slug}-#{date}-roster.csv"
  end

  private

  def enrollments
    @class_schedule.enrollments.includes(:user).order(:created_at)
  end

  def row_for(enrollment)
    [
      enrollment.attendee_name,
      enrollment.attendee_email,
      enrollment.country,
      enrollment.company_name,
      enrollment.status,
      invitation_status(enrollment),
      enrollment.created_at.iso8601
    ]
  end

  def invitation_status(enrollment)
    if enrollment.invitation_opened_at.present?
      "Opened"
    elsif enrollment.invitation_sent_at.present?
      "Sent"
    else
      "Not Sent"
    end
  end
end