class AboutController < ApplicationController
  def show
    @about_page = AboutPage.current
  end
end
