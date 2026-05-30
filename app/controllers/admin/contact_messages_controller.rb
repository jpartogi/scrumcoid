class Admin::ContactMessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!
  before_action :set_contact_message, only: [:show, :destroy, :mark_read, :archive]

  def index
    @contact_messages = ContactMessage.recent
  end

  def show
    @contact_message.read! if @contact_message.unread?
  end

  def destroy
    @contact_message.destroy
    redirect_to admin_contact_messages_path, notice: "Contact message deleted."
  end

  def mark_read
    @contact_message.read!
    redirect_to admin_contact_message_path(@contact_message), notice: "Contact message marked as read."
  end

  def archive
    @contact_message.archived!
    redirect_to admin_contact_messages_path, notice: "Contact message archived."
  end

  private

  def set_contact_message
    @contact_message = ContactMessage.find(params[:id])
  end
end
