class AddCompanyDetailsToEnrollments < ActiveRecord::Migration[8.1]
  def up
    add_column :enrollments, :company_name, :string
    add_column :enrollments, :company_address, :text
    add_column :enrollments, :company_phone, :string
    add_column :enrollments, :finance_name, :string
    add_column :enrollments, :finance_email, :string

    # Safe backfill of existing enrollments
    Enrollment.where.not(registration_id: nil).find_each do |enrollment|
      registration = enrollment.registration
      if registration.present?
        enrollment.update_columns(
          company_name: registration.company_name,
          company_address: registration.company_address,
          company_phone: registration.company_phone,
          finance_name: registration.finance_name,
          finance_email: registration.finance_email
        )
      end
    end
  end

  def down
    remove_column :enrollments, :company_name, :string
    remove_column :enrollments, :company_address, :text
    remove_column :enrollments, :company_phone, :string
    remove_column :enrollments, :finance_name, :string
    remove_column :enrollments, :finance_email, :string
  end
end
