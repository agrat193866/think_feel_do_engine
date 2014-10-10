require "spec_helper"

feature "admin dashboard" do
  fixtures :users, :user_roles

  context "user roles" do
    let(:admin1) { users(:admin1) }
    let(:user1) { users(:user1) }
    let(:user_role1) { user_roles(:user_role1) }
    let(:user_role_names) { user1.user_roles.map(&:role_class_name) }

    before do
      sign_in_user users :admin1
      visit "/admin/user_role"
    end

    it "assigns a new role to a user" do
      expect(user_role_names.include?("Roles::Researcher")).to eq false
      visit "/admin/user_role/new"
      select "user1@example.com", from: "User"
      select "Researcher", from: "User Role"
      click_on "Save"
      user1.reload
      user_roles = user1.user_roles.map(&:role_class_name)
      expect(user_roles.include?("Roles::Researcher")).to eq true
    end

    it "edits the role of a user" do
      expect(user_role_names.include?("Roles::Clinician")).to eq true
      expect(user_role_names.include?("Roles::Researcher")).to eq false
      visit "/admin/user_role/#{user_role1.id}/edit"
      select "Researcher", from: "User Role"
      click_on "Save"
      user1.reload
      user_roles = user1.user_roles.map(&:role_class_name)
      expect(user_roles.include?("Roles::Clinician")).to eq false
      expect(user_roles.include?("Roles::Researcher")).to eq true
    end
  end
end
