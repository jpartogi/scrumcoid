class ClassSchedulesController < ApplicationController
  def index
    @class_schedules = ClassSchedule.available.includes(course: [ :logo_attachment, :course_prices ])
  end

  def show
    @class_schedule = ClassSchedule.published.includes(:enrollments, course: [ :logo_attachment, :course_prices ]).find(params[:id])
    @enrollment = current_user&.enrollments&.find_by(class_schedule: @class_schedule)
  end
end
