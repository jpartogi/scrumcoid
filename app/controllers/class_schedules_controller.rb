class ClassSchedulesController < ApplicationController
  def index
    @class_schedules = ClassSchedule.available.includes(course: [ :logo_attachment, :course_prices ])
  end

  def show
    @class_schedule = ClassSchedule.published.includes(:enrollments, course: [ :logo_attachment, :course_prices ]).find(params[:id])
    @enrollment = current_user&.enrollments&.find_by(class_schedule: @class_schedule)
    flash.now[:notice] = "Payment received. Please check your email for instructions to join the class." if params[:checkout] == "success"
  end
end
