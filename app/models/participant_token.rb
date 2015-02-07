require "securerandom"

# Associates a Participant with an action on a date and provides an obfuscated
# token representation.
class ParticipantToken < ActiveRecord::Base
  TYPES = %w( phq9 wai )
  TOKEN_LENGTH = 10

  belongs_to :participant

  validates :participant, :token, :token_type, presence: true
  validates :token, uniqueness: { scope: :participant_id }
  validates :token_type, presence: { in: TYPES }

  before_validation :make_token

  def to_s
    token
  end

  private

  def make_token
    self.token = SecureRandom.hex(TOKEN_LENGTH)
  end
end
