class Admin::AboutPagesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!
  before_action :set_about_page

  def edit
  end

  def update
    if @about_page.update(about_page_params)
      redirect_to edit_admin_about_page_path, notice: "About page updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_about_page
    @about_page = AboutPage.current
  end

  def about_page_params
    params.require(:about_page).permit(:title, :summary, :body)
  end
end
