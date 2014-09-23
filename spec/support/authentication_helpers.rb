module AuthenticationHelpers
  def urls
    ThinkFeelDoEngine::Engine.routes.url_helpers
  end

  def sign_in_participant(participant)
    sign_out_participant participant
    visit urls.new_participant_session_path
    fill_in "Email", with: participant.email
    fill_in "Password", with: "secrets!"
    click_on "Sign in"
  end

  def sign_out_participant(participant)
    visit urls.destroy_participant_session_path
  end

  def sign_in_user(user)
    visit urls.destroy_user_session_path
    visit urls.new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "secrets!"
    click_on "Sign in"
  end
end
