require "test_helper"

class ResourceTest < ActiveSupport::TestCase
  test "generates slug from title when blank" do
    resource = Resource.new(title: "Scrum Guide PDF", description: "Content")
    resource.valid?
    assert_equal "scrum-guide-pdf", resource.slug
  end

  test "preserves custom slug when admin provides one" do
    resource = Resource.new(
      title: "Scrum Guide PDF",
      slug: "my-custom-slug",
      description: "Content"
    )
    resource.valid?
    assert_equal "my-custom-slug", resource.slug
  end

  test "does not overwrite slug when title changes on update" do
    resource = resources(:published_resource)
    resource.update!(title: "Completely New Title")
    assert_equal "scrum-cheat-sheet", resource.slug
  end

  test "defaults currency to IDR" do
    resource = Resource.new(title: "Test", description: "Content")
    resource.valid?
    assert_equal "IDR", resource.currency
  end

  test "paid? returns true when price is positive" do
    resource = resources(:published_resource)
    assert resource.paid?
    assert_not resources(:free_resource).paid?
  end

  test "display_price formats IDR with Indonesian convention" do
    resource = resources(:published_resource)
    assert_equal "IDR 150.000,-", resource.display_price
  end

  test "with_tag returns published resources sharing a tag" do
    posts = Resource.with_tag("SCRUM")
    assert_includes posts, resources(:published_resource)
    assert_not_includes posts, resources(:draft_resource)
  end

  test "related_resources returns published resources sharing at least one tag" do
    resource = resources(:published_resource)
    related = resource.related_resources
    assert_not_includes related, resource
    assert_not_includes related, resources(:draft_resource)
  end

  test "all_tags returns sorted unique tags from published resources" do
    assert_equal %w[agile scrum], Resource.all_tags
  end
end