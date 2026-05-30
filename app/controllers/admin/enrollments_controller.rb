class Admin::EnrollmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!
  before_action :set_enrollment, only: [:show, :edit, :update]

  def show
  end

  def edit
  end

  def update
    if @enrollment.update(enrollment_params)
      redirect_to admin_class_schedule_path(@enrollment.class_schedule), notice: "Student registration updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_enrollment
    @enrollment = Enrollment.find(params[:id])
  end

  def enrollment_params
    params.require(:enrollment).permit(:status, :visitor_name, :visitor_email)
  end
end
