require "spec_helper"

module ThinkFeelDoEngine
  module BitMaker
    urls = ThinkFeelDoEngine::Engine.routes.url_helpers

    describe SlideshowsController, type: :controller do
      let(:user) { double("user", admin?: true) }
      let(:slideshow) { double("slideshow") }
      let(:arm) { double("arm") }

      before do
        allow(arm).to receive(:bit_core_slideshows) { BitCore::Slideshow::ActiveRecord_Associations_CollectionProxy }
        allow(arm.bit_core_slideshows).to receive(:build) { slideshow }
        allow(Arm).to receive(:find) { arm }
      end

      describe "GET index" do
        context "for unauthenticated requests" do
          before { get :index, use_route: :think_feel_do_engine }
          it_behaves_like "a rejected user action"
        end

        context "for authenticated requests" do
          before do
            allow(BitCore::Slideshow).to receive(:all) { [] }
            sign_in_user user
            get :index, use_route: :think_feel_do_engine
          end

          it "should render the index page" do
            expect(response).to render_template :index
          end
        end
      end

      describe "GET new" do
        context "for unauthenticated requests" do
          before { get :new, use_route: :think_feel_do_engine }
          it_behaves_like "a rejected user action"
        end

        context "for authenticated requests" do
          before do
            allow(BitCore::Slideshow).to receive(:new) { slideshow }
            sign_in_user user
            get :new, use_route: :think_feel_do_engine
          end

          it "should render the new page" do
            expect(response).to render_template :new
          end
        end
      end

      describe "POST create" do
        context "for unauthenticated requests" do
          before { post :create, use_route: :think_feel_do_engine }
          it_behaves_like "a rejected user action"
        end
      end

      describe "PUT update" do
        context "for unauthenticated requests" do
          before { put :update, id: 1, use_route: :think_feel_do_engine }
          it_behaves_like "a rejected user action"
        end

        context "for authenticated requests" do
          before do
            allow(BitCore::Slideshow).to receive(:find) { slideshow }
            allow(arm.bit_core_slideshows).to receive(:find) { slideshow }
            sign_in_user user
          end

          context "when the slideshow does not save" do
            let(:errors) { double("errors", full_messages: []) }
            let(:slideshow) { double("slideshow", update: false, errors: errors) }

            it "should render the edit page" do
              put :update, id: 1, use_route: :think_feel_do_engine
              expect(response).to render_template :edit
            end
          end

          context "when the slideshow saves" do
            let(:slideshow) { double("slideshow", update: true) }

            it "should redirect to the slideshows page" do
              put :update, id: 1, use_route: :think_feel_do_engine
              expect(response).to redirect_to urls.arm_bit_maker_slideshows_url(arm)
            end
          end
        end
      end

      describe "DELETE destroy" do
        context "for unauthenticated requests" do
          before { delete :destroy, id: 1, use_route: :think_feel_do_engine }
          it_behaves_like "a rejected user action"
        end

        context "for authenticated requests" do
          before do
            allow(BitCore::Slideshow).to receive(:find) { slideshow }
            allow(arm.bit_core_slideshows).to receive(:find) { slideshow }
            sign_in_user user
          end

          context "when the slideshow is not destroyed" do
            let(:errors) { double("errors", full_messages: []) }
            let(:slideshow) { double("slideshow", destroy: false, errors: errors) }

            it "should redirect to the slideshows page" do
              delete :destroy, id: 1, use_route: :think_feel_do_engine
              expect(response).to redirect_to urls.arm_bit_maker_slideshows_url(arm)
            end
          end

          context "when the slideshow is destroyed" do
            let(:slideshow) { double("slideshow", destroy: true) }

            it "should redirect to the slideshows page" do
              delete :destroy, id: 1, use_route: :think_feel_do_engine
              expect(response).to redirect_to urls.arm_bit_maker_slideshows_url(arm)
            end
          end
        end
      end
    end
  end
end
