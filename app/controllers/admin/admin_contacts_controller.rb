class Admin::AdminContactsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!
  before_action :set_admin_contact, only: [:edit, :update, :destroy]

  def index
    @admin_contacts = AdminContact.order(:email)
  end

  def new
    @admin_contact = AdminContact.new
  end

  def edit
  end

  def create
    @admin_contact = AdminContact.new(admin_contact_params)

    if @admin_contact.save
      redirect_to admin_admin_contacts_path, notice: "Admin contact was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @admin_contact.update(admin_contact_params)
      redirect_to admin_admin_contacts_path, notice: "Admin contact was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @admin_contact.destroy
    redirect_to admin_admin_contacts_path, notice: "Admin contact was successfully deleted."
  end

  private

  def set_admin_contact
    @admin_contact = AdminContact.find(params[:id])
  end

  def admin_contact_params
    params.require(:admin_contact).permit(:email, :main, :name, :whatsapp_number)
  end
end
