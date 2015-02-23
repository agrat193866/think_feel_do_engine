require "rails_helper"

module ThinkFeelDoEngine
  module BitMaker
    describe SlidesController, type: :controller do
      let(:user) { double("user", admin?: true) }
      let(:slide_1) { double("slide1", position: 1, title: "some slide") }
      let(:slide_toc) { double("slide_toc", position: 1, title: "Table of Contents") }
      let(:slideshow_no_table_of_contents) do
        double("slideshow_no_toc",
               has_table_of_contents: false)
      end
      let(:slideshow_with_table_of_contents) do
        double("slideshow_with_toc",
               has_table_of_contents: true)
      end
      let(:slideshow_list) { double("slideshow_list") }
      let(:arm) { double("arm", bit_core_slideshows: slideshow_list) }

      context "authorized user" do
        it "allows regular slides to be sorted" do
          sign_in_user user

          allow(Arm).to receive(:find) { arm }
          allow(slideshow_list).to receive(:find) { slideshow_no_table_of_contents }
          allow(BitCore::Slide).to receive(:all)
          expect(BitCore::Slide).to receive(:find) { slide_1 }
          expect(slideshow_no_table_of_contents).to receive(:sort) { true }

          post :sort, use_route: :think_feel_do_engine, id: "1", slide: ["0", "1"]

          expect(session[:flash]).to eq("discard" => ["notice"], "flashes" => { "notice" => "Reorder was successful." })
        end

        it "prevents table of contents from being moved out of first"\
        " position" do
          sign_in_user user

          allow(Arm).to receive(:find) { arm }
          allow(slideshow_list).to receive(:find) { slideshow_with_table_of_contents }
          allow(BitCore::Slide).to receive(:all)
          expect(BitCore::Slide).to receive(:find) { slide_1 }

          post :sort, use_route: :think_feel_do_engine, id: "1", slide: ["0", "1"]

          expect(session[:flash]).to eq("discard" => [],
                                        "flashes" => { "alert" => "Table of contents cannot be moved out of the first position." })
        end
      end
    end
  end
end
