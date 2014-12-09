require "spec_helper"

feature "Content Provider", type: :feature do
  fixtures(
    :arms, :participants, :users, :user_roles, :"bit_core/slideshows", :"bit_core/slides",
    :"bit_core/tools", :"bit_core/content_modules",
    :"bit_core/content_providers", :groups, :memberships,
    :tasks, :task_status
  )

  context "Logged in as a content author" do

    before do
      sign_in_user users :content_author1
    end

    it "shoud have display a link to modules - not providers" do
      visit "/arms/#{arms(:arm1).id}/bit_maker/content_providers/#{bit_core_content_providers(:awake_period_form_provider).id}"

      expect(page).to have_text "Content Provider"
      expect(page).to have_text "#1 Awareness"
      expect(page).to_not have_link "Providers"
      expect(page).to have_link "Module", href: "/arms/#{arms(:arm1).id}/bit_maker/content_modules/#{bit_core_content_modules(:do_awareness).id}"
    end

    it "shoud have display a link to add provider" do
      visit "/arms/#{arms(:arm1).id}/bit_maker/content_modules"

      expect(page).to have_link "New Provider", href: "/arms/#{arms(:arm1).id}/bit_maker/content_providers/new"

      visit "/arms/#{arms(:arm1).id}/bit_maker/content_modules/#{bit_core_content_modules(:do_awareness).id}"

      expect(page).to have_link "New Provider", href: "/arms/#{arms(:arm1).id}/bit_maker/content_providers/new"
    end

    it "should scope modules by arm when on new" do
      visit "/arms/#{arms(:arm1).id}/bit_maker/content_providers/new"

      expect(page).to have_content "home: Landing"
      expect(page).to_not have_content "HOME: Landing"

      visit "/arms/#{arms(:arm2).id}/bit_maker/content_providers/new"

      expect(page).to_not have_content "home: Landing"
      expect(page).to have_content "HOME: Landing"
    end

    it "should scope modules by arm when on edit" do
      visit "/arms/#{arms(:arm1).id}/bit_maker/content_providers/#{bit_core_content_providers(:home_slideshow).id}/edit"

      expect(page).to have_content "Home Intro"
      expect(page).to_not have_content "HOME: Landing"

      visit "/arms/#{arms(:arm2).id}/bit_maker/content_providers/#{bit_core_content_providers(:home_slideshow_for_different_arm).id}/edit"

      expect(page).to_not have_content "Home Intro"
      expect(page).to have_content "HOME: Landing"
    end
  end
end