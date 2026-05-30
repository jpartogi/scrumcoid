class Admin::CoursesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!
  before_action :set_course, only: [:show, :edit, :update, :destroy, :publish, :unpublish]

  def index
    @courses = Course.with_attached_logo.includes(:class_schedules).order(:title)
  end

  def show
  end

  def new
    @course = Course.new
    @course.course_prices.build(currency: CurrencyResolver::DEFAULT_CURRENCY)
  end

  def edit
    @course.course_prices.build if @course.course_prices.empty?
  end

  def create
    @course = Course.new(course_params)

    if @course.save
      redirect_to admin_course_path(@course), notice: "Course created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @course.update(course_params)
      redirect_to admin_course_path(@course), notice: "Course updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @course.destroy
    redirect_to admin_courses_path, notice: "Course deleted."
  end

  def publish
    @course.published!
    redirect_to admin_course_path(@course), notice: "Course published."
  end

  def unpublish
    @course.draft!
    redirect_to admin_course_path(@course), notice: "Course unpublished."
  end

  private

  def set_course
    @course = Course.find_by!(slug: params[:id])
  end

  def course_params
    params.require(:course).permit(:title, :slug, :excerpt, :description, :status, :logo,
      course_prices_attributes: [:id, :currency, :amount, :_destroy])
  end
end
