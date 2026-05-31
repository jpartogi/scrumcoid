class Admin::RegistrationsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!

  def index
    @registrations = Registration.includes(:class_schedule, :enrollments).order(created_at: :desc)
  end

  def show
    @registration = Registration.find(params[:id])
  end
end
