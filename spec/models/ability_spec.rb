require "rails_helper"

describe Ability do
  describe "User permissions" do
    def role(name)
      UserRole.new(role_class_name: "Roles::#{ name }")
    end
    let(:superuser) { Ability.new(User.new(is_admin: true)) }
    let(:coach) { Ability.new(User.new(user_roles: [role("Clinician")])) }
    let(:content_author) do
      Ability.new(User.new(user_roles: [role("ContentAuthor")]))
    end
    let(:researcher) do
      Ability.new(User.new(user_roles: [role("Researcher")]))
    end
    let(:multi_role) do
      Ability.new(User.new(user_roles: [role("Clinician"), role("ContentAuthor"),
                                        role("Researcher")]))
    end

    describe "Superusers" do
      it "can manage all models" do
        expect(superuser.can?(:manage, :all)).to eq true
      end

      it "can read Reports" do
        expect(researcher.can?(:read, "Reports")).to eq true
      end
    end

    describe "Coaches" do
      it "can list all Arms" do
        expect(coach.can?(:index, Arm)).to eq true
      end

      it "cannot read Reports" do
        expect(coach.cannot?(:read, "Report")).to eq true
      end
    end

    describe "Content authors" do
      it "can view all Arms" do
        expect(content_author.can?(:read, Arm)).to eq true
      end

      it "cannot read Reports" do
        expect(coach.cannot?(:read, "Report")).to eq true
      end
    end

    describe "Researchers" do
      it "can view all Arms" do
        expect(researcher.can?(:show, Arm)).to eq true
      end

      it "can view all Tasks" do
        expect(researcher.can?(:read, Task)).to eq true
      end

      it "can read Reports" do
        expect(researcher.can?(:read, "Reports")).to eq true
      end
    end

    describe "Non-superuser, multi-role Users" do
      it "share all Roles' abilities" do
        expect(multi_role.can?(:manage, BitCore::ContentModule)).to eq true
        expect(multi_role.can?(:manage, Task)).to eq true
        expect(multi_role.can?(:read, "Reports")).to eq true
      end
    end
  end
end
