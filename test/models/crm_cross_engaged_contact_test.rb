require "test_helper"

class CrmCrossEngagedContactTest < ActiveSupport::TestCase
  test "all_scope returns visitors from resource downloads or meetup registrations" do
    leads = CrmCrossEngagedContact.all_scope
    emails = leads.map(&:visitor_email)

    assert_includes emails, "budi@example.com"
    assert_includes emails, "siti@example.com"
  end

  test "all_scope filters by name or email query" do
    leads = CrmCrossEngagedContact.all_scope(query: "Budi")

    assert_equal 1, leads.count
    assert_equal "budi@example.com", leads.first.visitor_email
  end

  test "total_count matches resource and meetup visitors" do
    assert_equal 2, CrmCrossEngagedContact.total_count
  end

  test "meetup-only visitors have zero resource downloads" do
    lead = CrmCrossEngagedContact.all_scope.find_by(visitor_email: "siti@example.com")

    assert_equal 0, lead.resource_download_count
    assert_equal 1, lead.meetup_registration_count
    assert_equal "Siti Rahayu", lead.display_name
  end

  test "display_name combines distinct visitor names" do
    lead = CrmCrossEngagedContact.all_scope.find_by(visitor_email: "budi@example.com")

    assert_equal "Budi Santoso", lead.display_name
  end
end