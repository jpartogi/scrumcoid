class Admin::StudentsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!

  def index
    @customers_count = Customer.count
    @students_count = Enrollment.count

    scope = Enrollment.includes(:user, class_schedule: :course, registration: :customer)
                      .order(created_at: :desc)

    scope = scope.matching_student_query(params[:query]) if params[:query].present?

    @enrollments = PaginatedScope.wrap(
      scope,
      page: params[:page],
      per_page: params[:per_page]
    )
  end
end