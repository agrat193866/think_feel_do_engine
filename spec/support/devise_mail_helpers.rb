module DeviseMailHelpers
  def last_email
    ActionMailer::Base.deliveries[0]
  end

  def clear_emails
    ActionMailer::Base.deliveries.clear
  end

  # Can be used like:
  #  extract_token_from_email(:reset_password)
  def extract_password_edit_path_from_email
    mail_body = last_email.body.to_s
    mail_body[/\/users\/password\/edit\?reset_password_token=[^"]+/]
  end

  def extract_participant_password_edit_path_from_email
    mail_body = last_email.body.to_s
    mail_body[/\/participants\/password\/edit\?reset_password_token=[^"]+/]
  end
end