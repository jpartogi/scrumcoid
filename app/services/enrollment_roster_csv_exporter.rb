require "csv"

class EnrollmentRosterCsvExporter
  def initialize(class_schedule)
    @class_schedule = class_schedule
  end

  def to_csv
    CSV.generate do |csv|
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
      first_name_for(enrollment),
      last_name_for(enrollment),
      enrollment.attendee_email,
      enrollment.country
    ]
  end

  def first_name_for(enrollment)
    enrollment.first_name.presence || enrollment.user&.name.to_s.split(/\s+/, 2).first.to_s
  end

  def last_name_for(enrollment)
    enrollment.last_name.presence || enrollment.user&.name.to_s.split(/\s+/, 2).last.to_s
  end
end