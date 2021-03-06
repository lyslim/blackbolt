class AppMailer < ActionMailer::Base

  helper ApplicationHelper

  def mail_signup_confirm( user, info )
    recipients user.email
    subject info[:subject]
    from ActionMailer::Base.smtp_settings[:app_default_from]
    body :user=>user, :info=>info
  end

  def mail_invite(user, info)
    recipients user.email
    subject info[:subject] 
    from ActionMailer::Base.smtp_settings[:app_default_from]
    body :user=>user, :info=>info
  end

  def mail_invite_project(user, info)
    recipients user.email
    subject info[:subject] 
    from ActionMailer::Base.smtp_settings[:app_default_from]
    body :user=>user, :info=>info
  end

  def mail_test( to, plan )
    recipients ""
    subject "Mail Test"
    from ActionMailer::Base.smtp_settings[:app_default_from]
  end
end
