require "rails_helper"

module ContentProviders
  describe LearnLessonsIndexProvider do
    let(:fake_raven) { double("Raven") }
    let(:provider) { LearnLessonsIndexProvider.new }
    let(:lesson) do
      instance_double(
        BitCore::ContentModule,
        tool: nil)
    end
    let(:membership) do
      instance_double(
        Membership,
        week_in_study: 1,
        start_date: Date.current)
    end
    let(:participant) do
      instance_double(
        Participant,
        active_membership: membership)
    end
    let(:options) { double("options") }
    let(:task) { instance_double(Task) }

    before do
      allow(options)
        .to receive(:app_context) { "LEARN" }
      allow(options)
        .to receive(:participant) { participant }
      allow(options)
        .to receive_message_chain("view_context.render")
      allow(participant)
        .to receive_message_chain("learning_tasks.includes.order")
      allow(provider).to receive(:content_module) { lesson }
      allow_any_instance_of(Range).to receive(:map)
      allow(ContentModules::LessonModule)
        .to receive_message_chain("joins.where.where.not")
      stub_const("Raven", fake_raven)
    end

    describe "render_current" do
      describe "when study_length_in_weeks is not defined" do
        it "Raven should send message" do
          expect(fake_raven)
            .to receive(:capture_message)
            .with("`study_length_in_weeks` is not configured in host app")

          provider.render_current(options)
        end
      end
    end
  end
end
