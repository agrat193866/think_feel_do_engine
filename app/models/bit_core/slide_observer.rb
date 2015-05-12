module BitCore
  # Listen for BitCore::Slide lifecycle events.
  # Registered in config/application.rb
  class SlideObserver < ActiveRecord::Observer
    def before_destroy(slide)
      MediaAccessEvent.where(bit_core_slide_id: slide.id).destroy_all
    end
  end
end
