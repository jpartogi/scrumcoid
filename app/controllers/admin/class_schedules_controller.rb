class Admin::ClassSchedulesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!
  before_action :set_class_schedule, only: [ :show, :edit, :update, :destroy, :publish, :unpublish ]

  def index
    @class_schedules = ClassSchedule.includes(:course, :enrollments).order(:starts_at)
  end

  def show
  end

  def new
    time_zone = Time.find_zone!(ClassSchedule::DEFAULT_TIMEZONE)
    starts_at = time_zone.now.advance(weeks: 2).change(hour: 9, min: 0, sec: 0)

    @class_schedule = ClassSchedule.new(
      starts_at: starts_at,
      ends_at: starts_at.change(hour: 17),
      registration_deadline: starts_at - 7.days,
      timezone: ClassSchedule::DEFAULT_TIMEZONE,
      capacity: 20,
      online: true
    )
  end

  def edit
  end

  def create
    @class_schedule = ClassSchedule.new(normalized_class_schedule_params)

    if @class_schedule.save
      redirect_to admin_class_schedule_path(@class_schedule), notice: "Class schedule created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @class_schedule.update(normalized_class_schedule_params)
      redirect_to admin_class_schedule_path(@class_schedule), notice: "Class schedule updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @class_schedule.destroy
    redirect_to admin_class_schedules_path, notice: "Class schedule deleted."
  end

  def publish
    @class_schedule.published!
    redirect_to admin_class_schedule_path(@class_schedule), notice: "Class schedule published."
  end

  def unpublish
    @class_schedule.unpublished!
    redirect_to admin_class_schedule_path(@class_schedule), notice: "Class schedule unpublished."
  end

  private

  def set_class_schedule
    @class_schedule = ClassSchedule.find(params[:id])
  end

  def class_schedule_params
    params.require(:class_schedule).permit(:course_id, :starts_at, :ends_at, :location, :online,
      :registration_deadline, :timezone, :capacity, :status, :venue_id)
  end

  def normalized_class_schedule_params
    attributes = class_schedule_params.to_h
    time_zone = Time.find_zone(attributes["timezone"].presence || @class_schedule&.timezone || ClassSchedule::DEFAULT_TIMEZONE)

    %w[starts_at ends_at registration_deadline].each do |attribute|
      attributes[attribute] = time_zone.parse(attributes[attribute]) if attributes[attribute].present? && time_zone
    end

    attributes
  end
end
