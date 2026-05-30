require "test_helper"

class Admin::CoursesControllerTest < ActionDispatch::IntegrationTest
  include ActionDispatch::TestProcess::FixtureFile

  test "admin courses index displays course logo" do
    sign_in users(:admin)
    course = courses(:ai_essentials)
    course.logo.attach(
      io: file_fixture("course-logo.png").open,
      filename: "course-logo.png",
      content_type: "image/png"
    )

    get admin_courses_path

    assert_response :success
    assert_select "img[alt='#{course.title} logo']"
  end

  test "admin can create course with multiple prices" do
    sign_in users(:admin)

    assert_difference -> { Course.count }, 1 do
      assert_difference -> { CoursePrice.count }, 2 do
        post admin_courses_path, params: {
          course: {
            title: "Professional Scrum with AI",
            slug: "professional-scrum-with-ai",
            excerpt: "A short course summary for the public courses page.",
            description: "A practical course for AI-enabled Scrum teams.",
            status: "published",
            course_prices_attributes: {
              "0" => { currency: "USD", amount: 1295.00 },
              "1" => { currency: "AUD", amount: 1950.00 }
            }
          }
        }
      end
    end

    course = Course.find_by!(slug: "professional-scrum-with-ai")
    assert_redirected_to admin_course_path(course)
    assert_equal ["AUD", "USD"], course.course_prices.pluck(:currency).sort
  end

  test "admin can add another price while editing course" do
    sign_in users(:admin)
    course = courses(:ai_essentials)

    assert_difference -> { course.course_prices.reload.count }, 1 do
      patch admin_course_path(course), params: {
        course: {
          title: course.title,
          slug: course.slug,
          excerpt: course.excerpt,
          description: course.description,
          status: course.status,
          course_prices_attributes: {
            "0" => { id: course_prices(:usd).id, currency: "USD", amount: 1295.00 },
            "1" => { currency: "EUR", amount: 1195.00 }
          }
        }
      }
    end

    assert_redirected_to admin_course_path(course)
    assert_includes course.course_prices.pluck(:currency), "EUR"
  end

  test "admin can upload course logo" do
    sign_in users(:admin)
    course = courses(:ai_essentials)
    logo = fixture_file_upload("course-logo.png", "image/png")

    patch admin_course_path(course), params: {
      course: {
        title: course.title,
        slug: course.slug,
        excerpt: course.excerpt,
        description: course.description,
        status: course.status,
        logo: logo
      }
    }

    assert_redirected_to admin_course_path(course)
    assert course.reload.logo.attached?
  end

  test "invalid course with uploaded logo rerenders form without signing unsaved attachment" do
    sign_in users(:admin)
    logo = fixture_file_upload("course-logo.png", "image/png")

    post admin_courses_path, params: {
      course: {
        title: "",
        slug: "",
        excerpt: "Invalid course excerpt.",
        description: "Missing title should rerender the form.",
        status: "draft",
        logo: logo
      }
    }

    assert_response :unprocessable_entity
    assert_match "Logo", response.body
  end
end
