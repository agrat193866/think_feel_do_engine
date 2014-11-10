# A message sent from the site to a Participant.
class SiteMessage < ActiveRecord::Base
  belongs_to :participant

  validates :participant, :subject, :body, presence: true
end
