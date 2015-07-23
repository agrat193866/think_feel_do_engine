require "rails_helper"

RSpec.describe "think_feel_do_engine/shared/user/_navbar", type: :view do
  context "when @navigator is not present" do
    it "does not render the hamburger button" do
      render partial: "think_feel_do_engine/shared/user/navbar",
             locals: { brand_location: "", current_user: nil }

      expect(rendered).not_to have_css(".navbar-toggle")
    end
  end

  context "when @navigator is present" do
    it "renders the hamburger button" do
      assign :navigator, double("navigator")

      render partial: "think_feel_do_engine/shared/user/navbar",
             locals: { brand_location: "", current_user: nil }

      expect(rendered).to have_css(".navbar-toggle")
    end
  end

  context "when there is not a current user" do
    it "does not render the sign out link" do
      render partial: "think_feel_do_engine/shared/user/navbar",
             locals: { brand_location: "", current_user: nil }

      expect(rendered).not_to have_link("Sign Out", "http")
    end
  end

  context "when there is a current user" do
    let(:user) { instance_double("User", email: "foo@bar.com") }

    it "renders the sign out link" do
      render partial: "think_feel_do_engine/shared/user/navbar",
             locals: {
               brand_location: "",
               current_user: user,
               destroy_user_session_path: ""
             }

      expect(rendered).to have_link("Sign Out", "http")
    end
  end
end
