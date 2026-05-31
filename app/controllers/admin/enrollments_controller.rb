class Admin::EnrollmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!
  before_action :set_enrollment, only: [:show, :edit, :update, :destroy]

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

  def destroy
    class_schedule = @enrollment.class_schedule
    @enrollment.destroy!
    redirect_to admin_class_schedule_path(class_schedule), notice: "Student registration has been permanently deleted."
  end

  private

  def set_enrollment
    @enrollment = Enrollment.find(params[:id])
  end

  def enrollment_params
    params.require(:enrollment).permit(
      :status, :visitor_name, :visitor_email,
      :company_name, :company_address, :company_phone,
      :finance_name, :finance_email
    )
  end
end
