require "spec_helper"

module ThinkFeelDoEngine
  urls = ThinkFeelDoEngine::Engine.routes.url_helpers

  describe LessonSlidesController, type: :controller do
    let(:user) { double("user", admin?: true) }
    let(:arm) { double("arm") }
    let(:lesson) { double("lesson") }
    let(:slide) { double("slide") }
    let(:model_errors) { double("errors", full_messages: []) }

    before do
      allow(ContentModules::LessonModule).to receive(:find) { lesson }
      allow(Arm).to receive(:find) { arm }
    end

    describe "GET new" do
      context "for unauthenticated requests" do
        before { get :new, lesson_id: 1, use_route: :think_feel_do_engine }
        it_behaves_like "a rejected user action"
      end

      context "for authenticated requests" do
        before do
          allow(lesson).to receive(:build_slide) { slide }
          sign_in_user user
          get :new, lesson_id: 1, use_route: :think_feel_do_engine
        end

        it "should render the new page" do
          expect(response).to render_template :new
        end
      end
    end

    describe "POST create" do
      context "for unauthenticated requests" do
        before { post :create, lesson_id: 1, use_route: :think_feel_do_engine }
        it_behaves_like "a rejected user action"
      end

      context "for authenticated requests" do
        context "when the slide saves successfully" do
          before do
            allow(lesson).to receive_message_chain(:build_slide) { slide }
            allow(slide).to receive(:save) { true }
            sign_in_user user
            post :create, lesson_id: 1, use_route: :think_feel_do_engine
          end

          it "should redirect to the lesson page" do
            expect(response).to redirect_to urls.arm_lesson_url(arm, lesson)
          end
        end
      end
    end

    describe "GET show" do
      context "for unauthenticated requests" do
        before { get :show, lesson_id: 1, id: 2, use_route: :think_feel_do_engine }
        it_behaves_like "a rejected user action"
      end

      context "for authenticated requests" do
        context "when the slide is found" do
          before do
            allow(BitCore::Slide).to receive(:find) { slide }
            sign_in_user user
            get :show, lesson_id: 1, id: 2, use_route: :think_feel_do_engine
          end

          it "should render the show page" do
            expect(response).to render_template :show
          end
        end

        context "when the slide is not found" do
          before do
            allow(BitCore::Slide).to receive(:find)
              .and_raise(ActiveRecord::RecordNotFound)
            sign_in_user user
            get :show, lesson_id: 1, id: 2, use_route: :think_feel_do_engine
          end

          it "should redirect to the lesson page" do
            expect(response).to redirect_to urls.arm_lesson_url(arm, lesson)
          end
        end
      end
    end

    describe "GET edit" do
      context "for unauthenticated requests" do
        before { get :edit, lesson_id: 1, id: 2, use_route: :think_feel_do_engine }
        it_behaves_like "a rejected user action"
      end

      context "for authenticated requests" do
        context "when the slide is found" do
          before do
            allow(BitCore::Slide).to receive(:find) { slide }
            sign_in_user user
            get :edit, lesson_id: 1, id: 2, use_route: :think_feel_do_engine
          end

          it "should render the edit page" do
            expect(response).to render_template :edit
          end
        end

        context "when the slide is not found" do
          before do
            allow(BitCore::Slide).to receive(:find)
              .and_raise(ActiveRecord::RecordNotFound)
            sign_in_user user
            get :edit, lesson_id: 1, id: 2, use_route: :think_feel_do_engine
          end

          it "should redirect to the lesson page" do
            expect(response).to redirect_to urls.arm_lesson_url(arm, lesson)
          end
        end
      end
    end

    describe "PUT update" do
      context "for unauthenticated requests" do
        before { put :update, lesson_id: 1, id: 2, use_route: :think_feel_do_engine }
        it_behaves_like "a rejected user action"
      end

      context "for authenticated requests" do
        context "when the slide is found" do
          before do
            allow(BitCore::Slide).to receive(:find) { slide }
            sign_in_user user
          end

          context "and updates successfully" do
            before do
              allow(slide).to receive(:update) { true }
              put :update, lesson_id: 1, id: 2, use_route: :think_feel_do_engine
            end

            it "should redirect to the lesson page" do
              expect(response).to redirect_to urls.arm_lesson_url(arm, lesson)
            end
          end

          context "and does not update successfully" do
            before do
              allow(slide).to receive(:update) { false }
              allow(slide).to receive(:errors) { model_errors }
              put :update, lesson_id: 1, id: 2, use_route: :think_feel_do_engine
            end

            it "should render the edit page" do
              expect(response).to render_template :edit
            end
          end
        end

        context "when the slide is not found" do
          before do
            allow(BitCore::Slide).to receive(:find)
              .and_raise(ActiveRecord::RecordNotFound)
            sign_in_user user
            put :update, lesson_id: 1, id: 2, use_route: :think_feel_do_engine
          end

          it "should redirect to the lesson page" do
            expect(response).to redirect_to urls.arm_lesson_url(arm, lesson)
          end
        end
      end
    end

    describe "DELETE destroy" do
      context "for unauthenticated requests" do
        before { delete :destroy, lesson_id: 1, id: 2, use_route: :think_feel_do_engine }
        it_behaves_like "a rejected user action"
      end

      context "for authenticated requests" do
        context "when the slide is found" do
          before do
            allow(BitCore::Slide).to receive(:find) { slide }
            sign_in_user user
          end

          context "and destroys successfully" do
            before do
              allow(lesson).to receive(:destroy_slide) { true }
              delete :destroy, lesson_id: 1, id: 2, use_route: :think_feel_do_engine
            end

            it "should redirect to the lesson page" do
              expect(response).to redirect_to urls.arm_lesson_url(arm, lesson)
            end
          end

          context "and does not destroy successfully" do
            before do
              allow(lesson).to receive(:destroy_slide) { false }
              allow(slide).to receive(:errors) { model_errors }
              delete :destroy, lesson_id: 1, id: 2, use_route: :think_feel_do_engine
            end

            it "should redirect to the lesson page" do
              expect(response).to redirect_to urls.arm_lesson_url(arm, lesson)
            end
          end
        end

        context "when the slide is not found" do
          before do
            allow(BitCore::Slide).to receive(:find)
              .and_raise(ActiveRecord::RecordNotFound)
            sign_in_user user
            delete :destroy, lesson_id: 1, id: 2, use_route: :think_feel_do_engine
          end

          it "should redirect to the lesson page" do
            expect(response).to redirect_to urls.arm_lesson_url(arm, lesson)
          end
        end
      end
    end
  end
end
