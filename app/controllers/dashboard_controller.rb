class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    @enrollments = current_user.enrollments.includes(class_schedule: :course).order("class_schedules.starts_at")
  end
end
