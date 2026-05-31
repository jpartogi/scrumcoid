class EnrollmentsController < ApplicationController
  before_action :authenticate_user!, only: [ :destroy ]
  before_action :set_class_schedule

  def destroy
    enrollment = current_user.enrollments.find_by!(class_schedule: @class_schedule)
    enrollment.cancelled!
    redirect_to dashboard_path, notice: "Your registration was cancelled."
  end

  private

  def set_class_schedule
    @class_schedule = ClassSchedule.includes(course: :course_prices).find(params[:class_schedule_id])
  end
end
