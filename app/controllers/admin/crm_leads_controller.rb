class Admin::CrmLeadsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!

  def index
    @customers_count = Customer.count
    @students_count = Enrollment.count
    @leads_count = CrmCrossEngagedContact.total_count

    scope = CrmCrossEngagedContact.all_scope(query: params[:query])

    @leads = PaginatedScope.wrap(
      scope,
      page: params[:page],
      per_page: params[:per_page]
    )
  end
end