require "event_capture/events_controller"

# Augment/override behavior.
class EventCapture::EventsController
  before_action :authenticate_participant!

  def event_params
    {
      kind: params[:kind],
      payload: params[:payload].merge(remote_ip: request.remote_ip),
      emitted_at: params[:emittedAt],
      participant_id: current_participant.id
    }
  end
end

require "event_capture/event"

class EventCapture::Event
  belongs_to :participant

  def self.next_event_for(event)
    where(participant_id: event.participant_id)
    .where.not(kind: "videoPlay")
    .where("emitted_at > ?", event.emitted_at)
    .select(:participant_id, :kind, :emitted_at)
    .order(:emitted_at)
    .limit(1)
    .first
  end

  def current_url
    payload[:currentUrl]
  end

  def button_html
    payload[:buttonHtml]
  end

  def headers
    payload[:headers]
  end
end
