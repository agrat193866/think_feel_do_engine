require "rails_helper"

module ThinkFeelDoEngine
  module BitMaker
    urls = ThinkFeelDoEngine::Engine.routes.url_helpers

    describe ContentProvidersController, type: :controller do
      let(:user) { double("user", admin?: true) }
      let(:arm) { double("arm", bit_core_tools: [], bit_core_slideshows: []) }
      let(:provider) { double("provider", source_content_id: nil) }

      before { allow(Arm).to receive(:find) { arm } }

      describe "GET index" do
        context "for unauthenticated requests" do
          before { get :index, use_route: :think_feel_do_engine }
          it_behaves_like "a rejected user action"
        end

        context "for authenticated requests" do
          before { sign_in_user user }

          context "when the provider is found" do
            before do
              allow(BitCore::ContentProvider).to receive(:all) { [] }
              get :index, use_route: :think_feel_do_engine
            end

            it "should render the index" do
              expect(response).to render_template :index
            end
          end
        end
      end

      describe "GET show" do
        context "for unauthenticated requests" do
          before { get :show, id: 1, use_route: :think_feel_do_engine }
          it_behaves_like "a rejected user action"
        end

        context "for authenticated requests" do
          before { sign_in_user user }

          context "when the provider is found" do
            before do
              allow(ContentProviderDecorator).to receive(:fetch) { provider }
              get :show, id: 1, use_route: :think_feel_do_engine
            end

            it "should render the show page" do
              expect(response).to render_template :show
            end
          end
        end
      end

      describe "GET edit" do
        context "for unauthenticated requests" do
          before { get :edit, id: 1, use_route: :think_feel_do_engine }
          it_behaves_like "a rejected user action"
        end

        context "for authenticated requests" do
          before { sign_in_user user }

          context "when the provider is found" do
            before do
              allow(ContentProviderDecorator).to receive(:fetch) { provider }
              get :edit, id: 1, use_route: :think_feel_do_engine
            end

            it "should render the edit page" do
              expect(response).to render_template :edit
            end
          end
        end
      end

      describe "POST create" do
        context "for unauthenticated requests" do
          before { post :create, use_route: :think_feel_do_engine }
          it_behaves_like "a rejected user action"
        end

        context "for authenticated requests" do
          before do
            sign_in_user user
            allow(ContentProviderDecorator).to receive(:new) { provider }
          end

          context "when the provider saves successfully" do
            before do
              allow(provider).to receive(:save) { true }
              post :create, content_provider: { type: nil }, use_route: :think_feel_do_engine
            end

            it "should redirect to the show page" do
              expect(response).to redirect_to urls.arm_bit_maker_content_provider_url(arm, provider)
            end
          end
        end
      end

      describe "PUT update" do
        context "for unauthenticated requests" do
          before { put :update, id: 1, use_route: :think_feel_do_engine }
          it_behaves_like "a rejected user action"
        end

        context "for authenticated requests" do
          before do
            sign_in_user user
            allow(ContentProviderDecorator).to receive(:fetch) { provider }
          end

          context "when the provider saves successfully" do
            before do
              allow(provider).to receive(:update) { true }
              put :update, id: 1, content_provider: { type: nil }, use_route: :think_feel_do_engine
            end

            it "should redirect to the show page" do
              expect(response).to redirect_to urls.arm_bit_maker_content_provider_url(arm, provider)
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
            sign_in_user user
            allow(ContentProviderDecorator).to receive(:fetch) { provider }
          end

          context "when the provider is destroyed successfully" do
            before do
              allow(provider).to receive(:destroy) { true }
              delete :destroy, id: 1, use_route: :think_feel_do_engine
            end

            it "should redirect to the index page" do
              expect(response).to redirect_to urls.arm_bit_maker_content_providers_url(arm)
            end
          end
        end
      end
    end
  end
end
