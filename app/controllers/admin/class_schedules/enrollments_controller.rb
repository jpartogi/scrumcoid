class Admin::ClassSchedules::EnrollmentsController < ApplicationController
  MAX_BATCH_SIZE = 20

  before_action :authenticate_user!
  before_action :authorize_admin!
  before_action :set_class_schedule

  def new
    if params[:count].blank?
      redirect_to admin_class_schedule_path(@class_schedule)
      return
    end

    @count = batch_count(params[:count])
    @enrollments = Array.new(@count) { @class_schedule.enrollments.build }
  end

  def create
    @enrollments = build_enrollments_from_params
    @count = @enrollments.size

    if @enrollments.all?(&:valid?)
      @enrollments.each(&:save!)
      notice = if @enrollments.size == 1
        "Student added to the roster successfully."
      else
        "#{@enrollments.size} students added to the roster successfully."
      end
      redirect_to admin_class_schedule_path(@class_schedule), notice: notice
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_class_schedule
    @class_schedule = ClassSchedule.find(params[:class_schedule_id])
  end

  def batch_count(value)
    count = value.to_i
    count = 1 if count < 1
    [count, MAX_BATCH_SIZE].min
  end

  def build_enrollments_from_params
    enrollment_batch_params.map do |attrs|
      enrollment = @class_schedule.enrollments.build(attrs)
      enrollment.skip_registration_limits = true
      enrollment
    end
  end

  def enrollment_batch_params
    params.fetch(:enrollments, {}).values.map do |attrs|
      attrs.permit(:first_name, :last_name, :email, :country).to_h
    end
  end
end