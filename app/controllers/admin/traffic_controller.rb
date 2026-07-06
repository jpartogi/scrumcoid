class Admin::TrafficController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!

  def show
    @report = TrafficReport.new(days: params[:days])
    @period_options = TrafficReport::PERIODS
  end
end