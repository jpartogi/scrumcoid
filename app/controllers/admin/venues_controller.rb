class Admin::VenuesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!
  before_action :set_venue, only: [ :show, :edit, :update, :destroy ]

  def index
    @venues = Venue.order(:name).includes(:class_schedules)
  end

  def show
  end

  def new
    @venue = Venue.new
  end

  def edit
  end

  def create
    @venue = Venue.new(venue_params)

    if @venue.save
      redirect_to admin_venue_path(@venue), notice: "Venue created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @venue.update(venue_params)
      redirect_to admin_venue_path(@venue), notice: "Venue updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @venue.destroy
    redirect_to admin_venues_path, notice: "Venue deleted."
  end

  private

  def set_venue
    @venue = Venue.find(params[:id])
  end

  def venue_params
    params.require(:venue).permit(:name, :address)
  end
end
