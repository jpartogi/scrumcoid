class InvitationTrackingController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:show], raise: false

  def show
    enrollment = Enrollment.find_by(invitation_token: params[:token])

    if enrollment
      enrollment.update!(invitation_opened_at: Time.current) if enrollment.invitation_opened_at.nil?
    end

    # Return a 1x1 transparent GIF
    gif_data = Base64.decode64("R0lGODlhAQABAPAAAP///wAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==")
    send_data gif_data, type: "image/gif", disposition: "inline"
  end
end
