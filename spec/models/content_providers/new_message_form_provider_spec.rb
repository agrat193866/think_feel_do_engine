require "rails_helper"

module ContentProviders
  describe NewMessageFormProvider do
    describe "render_current" do
      fixtures(:all)

      it "should send a inactive participant back to root" do
        new_message_form_provider = NewMessageFormProvider.new
        view_context_controller = double("view_context_controller")
        options = double("options",
                         participant: participants(:inactive_participant),
                         view_context: double("message_context"))
        params =
          { compose_path: "path",
            recipient: "recipient",
            recipient_id: "some_id",
            recipient_type: "recipient_type",
            subject: "subject" }
        content_module = double("content_module")

        expect(options.view_context).to receive(:controller) { view_context_controller }
        expect(view_context_controller).to receive(:redirect_to) { double("message_view") }
        expect(options.view_context).to receive(:root_url) { "the_root_url" }
        expect(options.view_context).to receive(:params) { params }
        expect(options.view_context).to receive(:participant_data_path)
        expect(new_message_form_provider).to receive(:message_for_reply)
        expect(new_message_form_provider).to receive(:message)
        expect(options.view_context).to receive(:params) { params }
        expect(options.view_context).to receive(:params) { params }
        expect(options.view_context).to receive(:params) { params }
        expect(options.view_context).to receive(:params) { params }
        expect(new_message_form_provider).to receive(:content_module) { content_module }
        expect(content_module).to receive(:tool)
        expect(options.view_context).to receive(:render)

        new_message_form_provider.render_current(options)
      end

      it "should send a active participant to the rendered message view" do
        new_message_form_provider = NewMessageFormProvider.new
        options = double("options",
                         participant: participants(:participant1),
                         view_context: double("message_context"))
        params =
          { compose_path: "path",
            recipient: "recipient",
            recipient_id: "some_id",
            recipient_type: "recipient_type",
            subject: "subject" }
        content_module = double("content_module")
        expect(options.view_context).to receive(:params) { params }
        expect(options.view_context).to receive(:participant_data_path)
        expect(new_message_form_provider).to receive(:message_for_reply)
        expect(new_message_form_provider).to receive(:message)
        expect(options.view_context).to receive(:params) { params }
        expect(options.view_context).to receive(:params) { params }
        expect(options.view_context).to receive(:params) { params }
        expect(options.view_context).to receive(:params) { params }
        expect(new_message_form_provider).to receive(:content_module) { content_module }
        expect(content_module).to receive(:tool)
        expect(options.view_context).to receive(:render)

        new_message_form_provider.render_current(options)
      end
    end
  end
end