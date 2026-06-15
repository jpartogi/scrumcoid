require "test_helper"

class InvitationTrackingControllerTest < ActionDispatch::IntegrationTest
  test "should track invitation email open with valid token" do
    enrollment = enrollments(:existing_registration)
    # Ensure it starts with no timestamps but has a token
    enrollment.update!(invitation_sent_at: 1.day.ago, invitation_opened_at: nil, invitation_token: "valid-token-xyz")
    assert_nil enrollment.invitation_opened_at

    get track_invitation_url(token: enrollment.invitation_token)

    assert_response :success
    assert_equal "image/gif", response.content_type
    assert_not_nil enrollment.reload.invitation_opened_at

    # Check that it returns the 1x1 transparent GIF data
    expected_gif = Base64.decode64("R0lGODlhAQABAPAAAP///wAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==")
    assert_equal expected_gif, response.body
  end

  test "should still return transparent GIF with invalid token without erroring" do
    assert_no_changes -> { Enrollment.where.not(invitation_opened_at: nil).count } do
      get track_invitation_url(token: "invalid-token")
    end

    assert_response :success
    assert_equal "image/gif", response.content_type
    expected_gif = Base64.decode64("R0lGODlhAQABAPAAAP///wAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==")
    assert_equal expected_gif, response.body
  end
end
