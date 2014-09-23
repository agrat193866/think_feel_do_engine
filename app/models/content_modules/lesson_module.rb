module ContentModules
  # Container for didactic content.
  class LessonModule < BitCore::ContentModule
    after_save :update_slideshow

    def self.sort(lesson_ids)
      start_position = BitCore::Tool.find_by_title("LEARN")
        .content_modules.where(type: [nil, "BitCore::ContentModule"])
        .order(position: :asc).maximum(:position) + 1
      transaction do
        connection.execute "SET CONSTRAINTS " \
                             "bit_core_content_module_position DEFERRED"
        lesson_ids.each_with_index do |id, idx|
          find(id).update_attribute(:position, idx + start_position)
        end
      end
    end

    def pretty_title
      return "" if title.nil?

      Redcarpet::Markdown.new(
        Redcarpet::Render::HTML.new(
          filter_html: true,
          safe_links_only: true
        )
      ).render(title).html_safe
    end

    def lesson_provider
      @lesson_provider ||= (content_providers.first ||
        add_content_provider("BitCore::ContentProviders::SlideshowProvider")
      )
    end

    def slides
      lesson_provider.source_content.slides || []
    end

    def build_slide(attrs = {})
      update_slideshow

      slides.build(attrs.merge(position: slides.count + 1))
    end

    def destroy_slide(slide)
      position = slide.position

      slide.transaction do
        if slide.destroy!
          slides.where("position > ?", position).each_with_index do |s, i|
            s.update_column(:position, position + i)
          end
        end
      end

      true

    rescue
      false
    end

    def sort(slide_ids)
      update_slideshow

      lesson_provider.source_content.sort(slide_ids)
    end

    private

    def update_slideshow
      lesson_provider.save

      lesson_provider.add_or_update_slideshow(title)
    end
  end
end
