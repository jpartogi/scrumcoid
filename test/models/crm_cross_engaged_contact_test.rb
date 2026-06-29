require "test_helper"

class CrmCrossEngagedContactTest < ActiveSupport::TestCase
  test "all_scope returns visitors present in both resource downloads and meetup registrations" do
    leads = CrmCrossEngagedContact.all_scope

    assert_includes leads.map(&:visitor_email), "budi@example.com"
    assert_not_includes leads.map(&:visitor_email), "siti@example.com"
  end

  test "all_scope filters by name or email query" do
    leads = CrmCrossEngagedContact.all_scope(query: "Budi")

    assert_equal 1, leads.count
    assert_equal "budi@example.com", leads.first.visitor_email
  end

  test "total_count matches cross-engaged visitors" do
    assert_equal 1, CrmCrossEngagedContact.total_count
  end

  test "display_name combines distinct visitor names" do
    lead = CrmCrossEngagedContact.all_scope.find_by(visitor_email: "budi@example.com")

    assert_equal "Budi Santoso", lead.display_name
  end
end