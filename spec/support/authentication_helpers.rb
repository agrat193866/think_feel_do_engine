module AuthenticationHelpers
  def urls
    ThinkFeelDoEngine::Engine.routes.url_helpers
  end

  def sign_in_participant(participant)
    sign_out_participant
    visit urls.new_participant_session_path
    fill_in "Email", with: participant.email
    fill_in "Password", with: "9ed56e32af0a77d8b60d85b3a6361054aa9306996a28eed36e95e87bef3642b3576239d978febfb2d21595a98dc4a48c7460b595d279d6f23a9d03d989bb1503"
    click_on "Sign in"
  end

  def sign_out_participant
    visit urls.destroy_participant_session_path
  end

  def sign_in_user(user)
    visit urls.destroy_user_session_path
    visit urls.new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "9ed56e32af0a77d8b60d85b3a6361054aa9306996a28eed36e95e87bef3642b3576239d978febfb2d21595a98dc4a48c7460b595d279d6f23a9d03d989bb1503"
    click_on "Sign in"
  end
end
