class Admin::RegistrationsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!
  before_action :set_registration, only: [:show, :destroy]

  def index
    @registrations = Registration.includes(:class_schedule, :enrollments).order(created_at: :desc)
  end

  def show
  end

  def destroy
    company = @registration.company_name
    @registration.destroy!
    redirect_to admin_registrations_path, notice: "Registration for \"#{company}\" and all its enrollments have been permanently deleted."
  end

  private

  def set_registration
    @registration = Registration.find(params[:id])
  end
end

