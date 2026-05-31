class Admin::AdminEmailsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!
  before_action :set_admin_email, only: [:edit, :update, :destroy]

  def index
    @admin_emails = AdminEmail.order(:email)
  end

  def new
    @admin_email = AdminEmail.new
  end

  def edit
  end

  def create
    @admin_email = AdminEmail.new(admin_email_params)

    if @admin_email.save
      redirect_to admin_admin_emails_path, notice: "Admin email was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @admin_email.update(admin_email_params)
      redirect_to admin_admin_emails_path, notice: "Admin email was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @admin_email.destroy
    redirect_to admin_admin_emails_path, notice: "Admin email was successfully deleted."
  end

  private

  def set_admin_email
    @admin_email = AdminEmail.find(params[:id])
  end

  def admin_email_params
    params.require(:admin_email).permit(:email, :main)
  end
end
