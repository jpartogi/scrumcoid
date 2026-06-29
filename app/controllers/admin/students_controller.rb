class Admin::StudentsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!

  def index
    @customers_count = Customer.count
    @students_count = Enrollment.count

    @enrollments = Enrollment.includes(:user, class_schedule: :course, registration: :customer)
                             .order(created_at: :desc)

    if params[:query].present?
      q = "%#{ActiveRecord::Base.sanitize_sql_like(params[:query])}%"
      @enrollments = @enrollments.left_joins(:user, registration: :customer).where(
        "enrollments.first_name LIKE :q OR enrollments.last_name LIKE :q OR enrollments.email LIKE :q " \
        "OR users.name LIKE :q OR users.email LIKE :q OR enrollments.company_name LIKE :q " \
        "OR registrations.company_name LIKE :q OR customers.company_name LIKE :q",
        q: q
      )
    end
  end
end