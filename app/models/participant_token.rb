require "securerandom"

# Associates a Participant with an action on a date and provides an obfuscated
# token representation.
class ParticipantToken < ActiveRecord::Base
  belongs_to :participant

  validates :participant, :token, :token_type, presence: true
  validates :token, uniqueness: { scope: :participant_id }

  before_validation :make_token

  def to_s
    token
  end

  private

  def make_token
    self.token = SecureRandom.hex(10)
  end
end
