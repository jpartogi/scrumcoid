module EnrollmentsHelper
  ADMIN_ENROLLMENT_RETURN_PREFIXES = %w[
    /admin/students
    /admin/customers
    /admin/class_schedules
  ].freeze

  def safe_enrollment_return_to(return_to)
    path = return_to.to_s.strip
    return if path.blank?
    return unless path.start_with?("/admin/")
    return if path.start_with?("//")
    return unless ADMIN_ENROLLMENT_RETURN_PREFIXES.any? { |prefix| path.start_with?(prefix) }

    path
  end

  def enrollment_return_query(return_to)
    safe_path = safe_enrollment_return_to(return_to)
    safe_path ? { return_to: safe_path } : {}
  end
end
