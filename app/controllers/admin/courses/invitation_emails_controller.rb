class Admin::Courses::InvitationEmailsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!
  before_action :set_course

  def show
  end

  def edit
  end

  def update
    if @course.update(invitation_email_params)
      redirect_to admin_course_invitation_email_path(@course), notice: "Invitation email template updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_course
    @course = Course.find_by!(slug: params[:course_id])
  end

  def invitation_email_params
    params.require(:course).permit(:invitation_email)
  end
end