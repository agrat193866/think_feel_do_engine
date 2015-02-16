require "rails_helper"

module ThinkFeelDoEngine
  urls = ThinkFeelDoEngine::Engine.routes.url_helpers

  describe ParticipantDataController, type: :controller do
    let(:provider) do
      double(
        "provider",
        data_class_name: "MyDataClass",
        data_attributes: [:attr1, :attr2]
      )
    end
    let(:navigator) { instance_double("Navigator", current_content_provider: provider) }
    let(:data_record) { double("data_record") }
    let(:participant) { double("participant", navigation_status: nil) }

    before do
      allow(BitPlayer::Navigator).to receive(:new) { navigator }
    end

    describe "POST create" do
      before do
        allow(participant).to receive(:build_data_record) { data_record }
      end

      context "when the participant is authenticated" do
        before { sign_in_participant participant }

        context "when the record saves" do
          before { allow(data_record).to receive(:save) { true } }

          it "should redirect to the next content" do
            post :create, my_data_class: { attr1: 1, attr2: 2 }, use_route: :think_feel_do_engine

            expect(response).to redirect_to(urls.navigator_next_content_url)
          end
        end

        context "when the record does not save" do
          let(:errors) { double("errors", full_messages: []) }

          before do
            allow(data_record).to receive(:save) { false }
            allow(data_record).to receive(:errors) { errors }
          end

          it "should re-render the content" do
            post :create, my_data_class: { attr1: 1, attr2: 2 }, use_route: :think_feel_do_engine

            expect(response).to render_template("think_feel_do_engine/navigator/show_content")
          end
        end

        context "when there is no associated data class found" do
          before { allow(provider).to receive(:data_class_name) { nil } }

          it "sets an error message" do
            post :create, my_data_class: { attr1: 1, attr2: 2 }, use_route: :think_feel_do_engine

            expect(flash[:alert]).to be_present
          end
        end
      end
    end

    describe "PUT update" do
      before do
        allow(participant).to receive(:fetch_data_record) { data_record }
      end

      context "when the participant is authenticated" do
        before { sign_in_participant participant }

        context "when the record saves" do
          before { allow(data_record).to receive(:update) { true } }

          it "should redirect to the next content" do
            put :update, my_data_class: { id: 123, attr1: 1, attr2: 2 }, use_route: :think_feel_do_engine

            expect(response).to redirect_to(urls.navigator_next_content_url)
          end
        end

        context "when the record does not save" do
          let(:errors) { double("errors", full_messages: []) }

          before do
            allow(data_record).to receive(:update) { false }
            allow(data_record).to receive(:errors) { errors }
          end

          it "should re-render the content" do
            put :update, my_data_class: { id: 123, attr1: 1, attr2: 2 }, use_route: :think_feel_do_engine

            expect(response).to render_template("think_feel_do_engine/navigator/show_content")
          end
        end
      end
    end
  end
end
