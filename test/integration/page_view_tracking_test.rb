require "test_helper"

class PageViewTrackingTest < ActionDispatch::IntegrationTest
  test "published blog post show tracks a unique page view" do
    post = blog_posts(:published_post)
    PageView.destroy_all

    real_ua = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

    assert_difference -> { PageView.where(viewable: post).count }, 1 do
      get blog_post_path(post), headers: { "User-Agent" => real_ua }
    end

    view = PageView.last
    assert_equal "BlogPost", view.viewable_type
    assert_equal post.id, view.viewable_id
    assert_equal Date.today, view.viewed_on
  end

  test "repeat visits to the same blog post on the same day do not create duplicate page views" do
    post = blog_posts(:published_post)
    PageView.destroy_all

    real_ua = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

    get blog_post_path(post), headers: { "User-Agent" => real_ua }

    assert_no_difference -> { PageView.where(viewable: post).count } do
      get blog_post_path(post), headers: { "User-Agent" => real_ua }
    end
  end

  test "published class schedule show tracks a unique page view" do
    schedule = class_schedules(:open_online)
    PageView.destroy_all

    real_ua = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

    assert_difference -> { PageView.where(viewable: schedule).count }, 1 do
      get class_schedule_path(schedule), headers: { "User-Agent" => real_ua }
    end
  end

  test "admin blog post show displays page view stats" do
    post = blog_posts(:published_post)
    PageView.destroy_all
    sign_in users(:admin)

    PageView.create!(viewable: post, fingerprint: "fp1", viewed_on: Date.today)
    PageView.create!(viewable: post, fingerprint: "fp2", viewed_on: Date.yesterday)

    get admin_blog_post_path(post)

    assert_response :success
    assert_select "p", text: "Today's Views"
    assert_select "p", text: "Total Unique Views"
    assert_select "h2", text: /Blog Post Traffic/
  end

  test "admin class schedule show displays page view stats" do
    schedule = class_schedules(:open_online)
    PageView.destroy_all
    sign_in users(:admin)

    PageView.create!(viewable: schedule, fingerprint: "fp1", viewed_on: Date.today)

    get admin_class_schedule_path(schedule)

    assert_response :success
    assert_select "p", text: "Today's Views"
    assert_select "h2", text: /Schedule Page Traffic/
  end

  test "admin blog post index displays page view counts" do
    post = blog_posts(:published_post)
    PageView.destroy_all
    sign_in users(:admin)

    PageView.create!(viewable: post, fingerprint: "fp1", viewed_on: Date.today)
    PageView.create!(viewable: post, fingerprint: "fp2", viewed_on: Date.yesterday)

    get admin_blog_posts_path

    assert_response :success
    assert_select "th", text: "Views"
    assert_match "2", response.body
  end

  test "admin class schedule index displays page view counts" do
    schedule = class_schedules(:open_online)
    PageView.destroy_all
    sign_in users(:admin)

    PageView.create!(viewable: schedule, fingerprint: "fp1", viewed_on: Date.today)

    get admin_class_schedules_path

    assert_response :success
    assert_select "th", text: "Views"
    assert_match "1", response.body
  end
end