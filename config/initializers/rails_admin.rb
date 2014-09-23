RailsAdmin.config do |config|

  ### Popular gems integration

  ## == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :user
  end

  config.current_user_method(&:current_user)

  ## == Cancan ==
  config.authorize_with :cancan

  ## == PaperTrail ==
  # config.audit_with :paper_trail, "User", "PaperTrail::Version" # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  config.included_models = %w{CoachAssignment Group Membership Participant User UserRole EventCapture::Event}

  config.actions do
    dashboard                     # mandatory
    root :manage
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end

  config.model "CoachAssignment" do
    navigation_label "Enrollment"

    list do
      field :coach
      field :participant do
        label do
          "Study Id"
        end
        pretty_value do
          value.try(:study_id) || "No Study ID"
        end
      end
    end

    show do
      field :coach
      field :participant do
        label do
          "Participant"
        end
        pretty_value do
          value.try(:study_id) || "No Study ID"
        end
      end
    end

    edit do
      # This view is also used in the new and edit of the Participant
      field :coach
      field :participant_id, :enum do
        help "Required"
        label do
          "Participant"
        end
        enum do # for select ;-)
          Participant.all.map { |p| [ (p.try(:study_id)|| "No Study ID"), p.id ] }
        end
      end
    end
  end

  config.model "Group" do
    navigation_label "Enrollment"

    list do
      sort_by :title
      field :title
      field :memberships_count do
        label do
          "Members"
        end
      end
      field :creator
      field :created_at
    end

    edit do
      field :title
      field :creator
    end
  end

  config.model "Membership" do
    navigation_label "Enrollment"

    list do
      field :group
      field :participant do
        pretty_value do
          value.try(:study_id) || "No Study ID"
        end
      end
      field :start_date
      field :end_date
    end

    show do
      field :group
      field :participant do
        label do
          "Study Id"
        end
        pretty_value do
          value.try(:study_id) || "No Study ID"
        end
      end
      field :start_date_american
      field :end_date_american
    end

    edit do
      field :group
      field :participant_id, :enum do
        label do
          "Participant"
        end
        enum do # for select ;-)
          Participant.all.map { |p| [ (p.try(:study_id) || "No Study ID" ), p.id ] }
        end
      end
      field :start_date_american
      field :end_date_american
    end
  end

  config.model "Participant" do
    navigation_label "Enrollment"

    list do
      sort_by :study_id
      field :study_id do
        label do
          "Study Id"
        end
        pretty_value do
          value || "No Study ID"
        end
      end
      field :groups
    end

    show do
      field :study_id do
        label do
          "Study Id"
        end
        pretty_value do
          value || "No Study ID"
        end
      end
      field :groups
      field :active_group
      field :activities
      field :thoughts
      field :coach_assignment
      field :coach
      field :sign_in_count
    end

    edit do
      field :study_id do
        label do
          "Study Id"
        end
        pretty_value do
          value || "No Study ID"
        end
      end
      field :email
      field :password
      field :password_confirmation
    end
  end

  config.model "UserRole" do
    navigation_label "Enrollment"

    list do
      sort_by :user
      field :user
      field :role_class_name do
        pretty_value do
          value.demodulize.titleize
        end
      end
      configure :role_class_name do
        label "Role"
      end
    end

    show do
      field :user
      field :role_class_name do
        pretty_value do
          value.demodulize.titleize
        end
      end
      configure :role_class_name do
        label "Role"
      end
    end

    edit do
      field :user
      field :role_class_name, :enum do
        label do
          "User Role"
        end
        enum do
          UserRole::ROLES.map { |r| [r.demodulize.titleize, r] }
        end
      end
    end

  end

  config.model "User" do
    navigation_label "Enrollment"

    object_label_method do
      :email
    end

    list do
      sort_by :email
      field :email
      field :is_admin
      field :user_roles do
        pretty_value do
          value.map{ |m| m.role_class_name.demodulize.titleize }.to_sentence
        end
      end
      configure :user_roles do
        label "Roles"
      end
      field :last_sign_in_at
    end

    show do
      field :email
      field :sign_in_count
      field :current_sign_in_at
      field :last_sign_in_at
      field :current_sign_in_ip
      field :last_sign_in_ip
      field :is_admin
      field :coach_assignments
      field :participants
      field :created_groups
      field :user_roles do
        pretty_value do
          value.map{ |m| m.role_class_name.demodulize.titleize }.to_sentence
        end
      end
      configure :user_roles do
        label "Roles"
      end
    end

    edit do
      field :email
      field :password
      field :password_confirmation
      field :is_admin
    end
  end

  config.model "EventCapture::Event" do
    list do
      field :participant do
        label do
          "Study Id"
        end
        pretty_value do
          value.try(:study_id) || "No Study ID"
        end
      end
      field :emitted_at do
        pretty_value do
          value.strftime "%Y-%m-%d %k:%M:%S"
        end
      end
      field :kind
      field :current_url do
        pretty_value do
          value && value.gsub(SteppedCareReboot::Application.routes.url_helpers.root_url, "")
        end
      end
    end

    export do
      field :participant do
        label do
          "Study Id"
        end
        pretty_value do
          value.try(:study_id) || "No Study ID"
        end
      end
      field :emitted_at do
        pretty_value do
          value.strftime "%Y-%m-%d %k:%M:%S"
        end
      end
      field :kind
      field :current_url do
        pretty_value do
          value && value.gsub(SteppedCareReboot::Application.routes.url_helpers.root_url, "")
        end
      end
      field :button_html
      field :headers
    end
  end
end
