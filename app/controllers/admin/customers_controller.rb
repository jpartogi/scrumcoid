class Admin::CustomersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!
  before_action :set_customer, only: [:show, :edit, :update, :destroy]

  def index
    @customers_count = Customer.count
    @students_count = Enrollment.count
    @leads_count = CrmCrossEngagedContact.total_count

    @customers = Customer.left_joins(:registrations)
                         .group(:id)
                         .select("customers.*, COUNT(registrations.id) as registrations_count")
                         .order("customers.company_name")

    if params[:query].present?
      q = "%#{params[:query]}%"
      @customers = @customers.where("customers.company_name LIKE ? OR customers.finance_name LIKE ? OR customers.finance_email LIKE ?", q, q, q)
    end
  end

  def show
    @registrations = @customer.registrations.includes(:class_schedule => :course).order(created_at: :desc)
    @enrollments = @customer.enrollments.includes(:class_schedule => :course).order(created_at: :desc)
  end

  def edit
  end

  def update
    if @customer.update(customer_params)
      redirect_to admin_customer_path(@customer), notice: "Customer was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @customer.destroy
    redirect_to admin_customers_path, notice: "Customer was successfully deleted."
  end

  private

  def set_customer
    @customer = Customer.find(params[:id])
  end

  def customer_params
    params.require(:customer).permit(:company_name, :company_phone, :company_address, :finance_name, :finance_email)
  end
end
