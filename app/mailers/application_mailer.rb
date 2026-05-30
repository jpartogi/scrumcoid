class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM", "no-reply@scrumcoid.fly.dev")
  layout "mailer"
end
