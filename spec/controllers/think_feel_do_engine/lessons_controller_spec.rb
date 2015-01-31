require "spec_helper"

module ThinkFeelDoEngine
  urls = ThinkFeelDoEngine::Engine.routes.url_helpers

  describe ThinkFeelDoEngine::LessonsController, type: :controller do
    let(:arm) { double("arm", bit_core_tools: BitCore::Tool, id: 123) }
    let(:user) { double("user", admin?: true) }

    describe "GET index" do
      context "for unauthenticated requests" do
        before { get :index, use_route: :think_feel_do_engine }
        it_behaves_like "a rejected user action"
      end

      context "for authenticated requests" do
        let(:lesson) { double("lesson") }

        before do
          allow(controller).to receive(:set_lesson).and_return(lesson)
          allow(Arm).to receive(:find) { arm }
          allow(ContentModules::LessonModule).to receive_message_chain(:includes, :order) { [] }
          sign_in_user user
          get :index, use_route: :think_feel_do_engine
        end

        it "should render the index page" do
          expect(response).to render_template :index
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

        context "when the lesson is not found" do
          before do
            allow(Arm).to receive(:find) { arm }
            allow(ContentModules::LessonModule).to receive(:find)
              .and_raise(ActiveRecord::RecordNotFound)
          end

          it "should redirect to the index page" do
            get :show, id: 1, use_route: :think_feel_do_engine

            expect(response).to redirect_to urls.arm_lessons_url(arm)
          end
        end

        context "when the lesson is found" do
          let(:lesson) { double("lesson") }

          before do
            allow(controller).to receive(:set_lesson).and_return(lesson)
            allow(Arm).to receive(:find) { arm }
          end

          it "should render the show page" do
            get :show, id: 1, use_route: :think_feel_do_engine

            expect(response).to render_template :show
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
        let(:tool) { double("tool", add_module: lesson, content_modules: ContentModules::LessonModule) }

        before do
          allow(Arm).to receive(:find) { arm }
          allow(BitCore::Tool).to receive(:find_by_type) { tool }
          sign_in_user user
        end

        context "when the lesson does not save" do
          let(:errors) { double("errors", full_messages: []) }
          let(:lesson) { double("lesson", save: false, errors: errors) }

          it "should render the new page" do
            allow(controller).to receive(:set_lesson_tool).and_return(lesson)
            allow(controller).to receive(:set_lesson).and_return(lesson)
            post :create, use_route: :think_feel_do_engine

            expect(response).to render_template :new
          end
        end

        context "when the lesson saves" do
          let(:lesson) { double("lesson", save: true) }

          it "should redirect to the lesson page" do
            allow(controller).to receive(:set_lesson).and_return(lesson)
            post :create, use_route: :think_feel_do_engine
            expect(response).to redirect_to urls.arm_lesson_url(arm, lesson)
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
          allow(Arm).to receive(:find) { arm }
          sign_in_user user
        end

        context "when the lesson does not save" do
          let(:errors) { double("errors", full_messages: []) }
          let(:lesson) { double("lesson", update: false, errors: errors) }
          let(:bit_core_content_module) { double("bit_core_content_module") }

          it "should render the edit page" do
            allow(ContentModules::LessonModule).to receive(:where) { bit_core_content_module }
            allow(bit_core_content_module).to receive(:find).and_return(lesson)
            put :update, id: 1, use_route: :think_feel_do_engine

            expect(response).to render_template :edit
          end
        end

        context "when the lesson saves" do
          let(:lesson) { double("lesson", update: true) }
          let(:bit_core_content_module) { double("bit_core_content_module") }

          it "should redirect to the lesson page" do
            allow(ContentModules::LessonModule).to receive(:where) { bit_core_content_module }
            allow(bit_core_content_module).to receive(:find).and_return(lesson)
            put :update, id: 1, use_route: :think_feel_do_engine

            expect(response).to redirect_to urls.arm_lesson_url(arm, lesson)
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
          allow(Arm).to receive(:find) { arm }
          sign_in_user user
        end

        context "when the lesson is not destroyed" do
          let(:errors) { double("errors", full_messages: []) }
          let(:lesson) { double("lesson", destroy: false, errors: errors) }

          it "should redirect to the lessons page" do
            allow(controller).to receive(:set_lesson).and_return(lesson)
            delete :destroy, id: 1, use_route: :think_feel_do_engine
            expect(response).to redirect_to urls.arm_lessons_url(arm)
          end
        end

        context "when the lesson is destroyed" do
          let(:lesson) { double("lesson", id: 1, destroy: true) }

          it "should redirect to the lessons page" do
            allow(controller).to receive(:set_lesson).and_return(lesson)
            delete :destroy, id: 1, use_route: :think_feel_do_engine
            expect(response).to redirect_to urls.arm_lessons_url(arm)
          end
        end
      end
    end

    describe "POST sort" do
      context "for unauthenticated requests" do
        before { post :sort, use_route: :think_feel_do_engine }
        it_behaves_like "a rejected user action"
      end

      context "for authenticated requests" do
        before do
          allow(Arm).to receive(:find) { arm }
          sign_in_user user
        end

        context "when the lesson sorts" do
          let(:lesson) { class_double("ContentModules::LessonModule").as_stubbed_const }

          it "doesn't throw an exception" do
            allow(lesson).to receive(:sort) { true }
            post :sort, use_route: :think_feel_do_engine
            expect(response).to be_success
          end
        end
      end
    end
  end
end
