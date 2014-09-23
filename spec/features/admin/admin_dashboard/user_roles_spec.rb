require "spec_helper"

feature "admin dashboard" do
  fixtures :users, :user_roles

  context "user roles" do
    let(:admin1) { users(:admin1) }
    let(:user1) { users(:user1) }
    let(:user_role1) { user_roles(:user_role1) }

    before do
      sign_in_user users :admin1
      visit "/admin/user_role"
    end

    it "assigns a new role to a user" do
      user_roles = user1.user_roles.map { |role| role.role_class_name }
      expect(user_roles.include?("Roles::Researcher")).to eq false
      visit "/admin/user_role/new"
      select "user1@example.com", from: "User"
      select "Researcher", from: "User Role"
      click_on "Save"
      user1.reload
      user_roles = user1.user_roles.map { |role| role.role_class_name }
      expect(user_roles.include?("Roles::Researcher")).to eq true
    end

    it "edits the role of a user" do
      user_roles = user1.user_roles.map { |role| role.role_class_name }
      expect(user_roles.include?("Roles::Clinician")).to eq true
      expect(user_roles.include?("Roles::Researcher")).to eq false
      visit "/admin/user_role/#{user_role1.id}/edit"
      select "Researcher", from: "User Role"
      click_on "Save"
      user1.reload
      user_roles = user1.user_roles.map { |role| role.role_class_name }
      expect(user_roles.include?("Roles::Clinician")).to eq false
      expect(user_roles.include?("Roles::Researcher")).to eq true
    end
  end
end
