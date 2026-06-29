class Admin::StudentsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!

  def index
    @customers_count = Customer.count
    @students_count = Enrollment.count
    @leads_count = CrmCrossEngagedContact.total_count

    sort_column    = %w[student training_schedule].include?(params[:sort]) ? params[:sort] : nil
    sort_direction = params[:direction] == "asc" ? "asc" : "desc"

    @sort_column    = sort_column
    @sort_direction = sort_direction

    scope = Enrollment.includes(:user, class_schedule: :course, registration: :customer)
    scope = if sort_column
      scope.ordered_for_admin(sort_column, sort_direction)
    else
      scope.order(created_at: :desc)
    end

    scope = scope.matching_student_query(params[:query]) if params[:query].present?

    @enrollments = PaginatedScope.wrap(
      scope,
      page: params[:page],
      per_page: params[:per_page]
    )
  end
end