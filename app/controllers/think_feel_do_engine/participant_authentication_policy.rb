module ThinkFeelDoEngine
  # Defines the behavior surrounding Participant authentication.
  class ParticipantAuthenticationPolicy
    def initialize(controller, participant)
      @controller = controller
      @participant = participant
    end

    def post_sign_in_path
      "/"
    end
  end
end
