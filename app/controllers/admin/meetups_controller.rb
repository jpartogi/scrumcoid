class Admin::MeetupsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!
  before_action :set_meetup, only: [:show, :edit, :update, :destroy, :publish, :unpublish]

  def index
    @meetups = Meetup.order(:starts_at)
    @page_view_counts = PageView.unique_view_counts_for("Meetup", @meetups.map(&:id))
  end

  def show
    @registrations = @meetup.meetup_registrations.active.order(created_at: :desc)
    @page_view_stats = @meetup.page_view_stats
  end

  def new
    time_zone = Time.find_zone!(Meetup::DEFAULT_TIMEZONE)
    starts_at = time_zone.now.advance(weeks: 2).change(hour: 19, min: 0, sec: 0)
    ends_at = starts_at.change(hour: 21, min: 0)

    @meetup = Meetup.new(
      name: Meetup::DEFAULT_NAME,
      starts_at: starts_at,
      ends_at: ends_at,
      registration_deadline: starts_at - 1.day,
      timezone: Meetup::DEFAULT_TIMEZONE,
      capacity: 100,
      status: "published"
    )
  end

  def edit
  end

  def create
    @meetup = Meetup.new(normalized_meetup_params)

    if @meetup.save
      redirect_to admin_meetup_path(@meetup), notice: "Meetup created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @meetup.update(normalized_meetup_params)
      redirect_to admin_meetup_path(@meetup), notice: "Meetup updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @meetup.destroy
    redirect_to admin_meetups_path, notice: "Meetup deleted."
  end

  def publish
    @meetup.published!
    redirect_to admin_meetup_path(@meetup), notice: "Meetup published."
  end

  def unpublish
    @meetup.draft!
    redirect_to admin_meetup_path(@meetup), notice: "Meetup unpublished."
  end

  private

  def set_meetup
    @meetup = Meetup.find_by!(slug: params[:id])
  end

  def meetup_params
    params.require(:meetup).permit(
      :name, :excerpt, :description, :starts_at, :ends_at, :timezone,
      :join_link, :paypal_donation_url, :capacity, :registration_deadline, :status, :meta_keywords, :online
    )
  end

  def normalized_meetup_params
    attributes = meetup_params.to_h
    time_zone = Time.find_zone(attributes["timezone"].presence || @meetup&.timezone || Meetup::DEFAULT_TIMEZONE)

    %w[starts_at ends_at registration_deadline].each do |attribute|
      attributes[attribute] = time_zone.parse(attributes[attribute]) if attributes[attribute].present? && time_zone
    end

    attributes
  end
end