require "test_helper"

class PageViewTest < ActiveSupport::TestCase
  test "track! creates a unique record per viewable fingerprint and day" do
    post = blog_posts(:published_post)
    PageView.destroy_all

    PageView.track!(viewable: post, fingerprint: "abc", viewed_on: Date.today)
    PageView.track!(viewable: post, fingerprint: "abc", viewed_on: Date.today)

    assert_equal 1, PageView.where(viewable: post).count
  end

  test "unique_view_counts_for returns distinct fingerprint counts per viewable" do
    post = blog_posts(:published_post)
    other = blog_posts(:related_post)
    PageView.destroy_all

    PageView.create!(viewable: post, fingerprint: "fp1", viewed_on: Date.today)
    PageView.create!(viewable: post, fingerprint: "fp2", viewed_on: Date.yesterday)
    PageView.create!(viewable: other, fingerprint: "fp3", viewed_on: Date.today)

    counts = PageView.unique_view_counts_for("BlogPost", [post.id, other.id])

    assert_equal 2, counts[post.id]
    assert_equal 1, counts[other.id]
  end

  test "prune_old! removes records older than retention window" do
    post = blog_posts(:published_post)
    PageView.destroy_all

    PageView.create!(viewable: post, fingerprint: "old", viewed_on: 100.days.ago.to_date)
    PageView.create!(viewable: post, fingerprint: "recent", viewed_on: Date.today)

    assert_difference -> { PageView.count }, -1 do
      PageView.prune_old!(retention_days: 90)
    end

    assert_equal "recent", PageView.last.fingerprint
  end
end