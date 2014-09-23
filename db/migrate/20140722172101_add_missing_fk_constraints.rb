class AddMissingFkConstraints < ActiveRecord::Migration
  def change
    EmotionalRating.where(emotion_id: nil).destroy_all
    EmotionalRating.all.each do |r|
      r.destroy if r.emotion.nil?
    end
    CoachAssignment.all.each do |a|
      a.destroy if a.participant.nil?
    end
    ContentProviderPolicy.all.each do |p|
      p.destroy if p.content_provider.nil?
    end
    Engagement.all.each do |e|
      e.destroy if e.task_status.nil?
    end
    Task.all.each do |t|
      t.destroy if t.bit_core_content_module.nil?
    end
    change_column_null :emotional_ratings, :participant_id, false
    change_column_null :emotional_ratings, :emotion_id, false
    change_column_null :emotions, :name, false
    change_column_null :engagements, :task_status_id, false
    change_column_null :slideshow_anchors, :bit_core_slideshow_id, false
    change_column_null :task_statuses, :membership_id, false
    change_column_null :task_statuses, :task_id, false
    change_column_null :tasks, :group_id, false
    change_column_null :tasks, :bit_core_content_module_id, false

    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE coach_assignments
            ADD CONSTRAINT fk_coach_assignments_participants
            FOREIGN KEY (participant_id)
            REFERENCES participants(id)
        SQL
        execute <<-SQL
          ALTER TABLE coach_assignments
            ADD CONSTRAINT fk_coach_assignments_users
            FOREIGN KEY (coach_id)
            REFERENCES users(id)
        SQL
        execute <<-SQL
          ALTER TABLE content_provider_policies
            ADD CONSTRAINT fk_coach_content_providers_policies
            FOREIGN KEY (bit_core_content_provider_id)
            REFERENCES bit_core_content_providers(id)
        SQL
        execute <<-SQL
          ALTER TABLE emotional_ratings
            ADD CONSTRAINT fk_emotional_ratings_participants
            FOREIGN KEY (participant_id)
            REFERENCES participants(id)
        SQL
        execute <<-SQL
          ALTER TABLE emotional_ratings
            ADD CONSTRAINT fk_emotional_ratings_emotions
            FOREIGN KEY (emotion_id)
            REFERENCES emotions(id)
        SQL
        execute <<-SQL
          ALTER TABLE emotions
            ADD CONSTRAINT fk_emotions_participants
            FOREIGN KEY (creator_id)
            REFERENCES participants(id)
        SQL
        execute <<-SQL
          ALTER TABLE engagements
            ADD CONSTRAINT fk_engagements_task_statuses
            FOREIGN KEY (task_status_id)
            REFERENCES task_statuses(id)
        SQL
        execute <<-SQL
          ALTER TABLE groups
            ADD CONSTRAINT fk_groups_creators
            FOREIGN KEY (creator_id)
            REFERENCES users(id)
        SQL
        execute <<-SQL
          ALTER TABLE moods
            ADD CONSTRAINT fk_moods_participants
            FOREIGN KEY (participant_id)
            REFERENCES participants(id)
        SQL
        execute <<-SQL
          ALTER TABLE participant_login_events
            ADD CONSTRAINT fk_login_events_participants
            FOREIGN KEY (participant_id)
            REFERENCES participants(id)
        SQL
        execute <<-SQL
          ALTER TABLE slideshow_anchors
            ADD CONSTRAINT fk_slideshows_anchors
            FOREIGN KEY (bit_core_slideshow_id)
            REFERENCES bit_core_slideshows(id)
        SQL
        execute <<-SQL
          ALTER TABLE task_statuses
            ADD CONSTRAINT fk_task_statuses_memberships
            FOREIGN KEY (membership_id)
            REFERENCES memberships(id)
        SQL
        execute <<-SQL
          ALTER TABLE task_statuses
            ADD CONSTRAINT fk_tasks_statuses
            FOREIGN KEY (task_id)
            REFERENCES tasks(id)
        SQL
        execute <<-SQL
          ALTER TABLE tasks
            ADD CONSTRAINT fk_tasks_groups
            FOREIGN KEY (group_id)
            REFERENCES groups(id)
        SQL
        execute <<-SQL
          ALTER TABLE tasks
            ADD CONSTRAINT fk_tasks_modules
            FOREIGN KEY (bit_core_content_module_id)
            REFERENCES bit_core_content_modules(id)
        SQL
      end

      dir.down do
        execute <<-SQL
          ALTER TABLE coach_assignments
            DROP CONSTRAINT fk_coach_assignments_participants
        SQL
        execute <<-SQL
          ALTER TABLE coach_assignments
            DROP CONSTRAINT fk_coach_assignments_users
        SQL
        execute <<-SQL
          ALTER TABLE content_provider_policies
            DROP CONSTRAINT fk_coach_content_providers_policies
        SQL
        execute <<-SQL
          ALTER TABLE emotional_ratings
            DROP CONSTRAINT fk_emotional_ratings_participants
        SQL
        execute <<-SQL
          ALTER TABLE emotional_ratings
            DROP CONSTRAINT fk_emotional_ratings_emotions
        SQL
        execute <<-SQL
          ALTER TABLE emotions
            DROP CONSTRAINT fk_emotions_participants
        SQL
        execute <<-SQL
          ALTER TABLE engagements
            DROP CONSTRAINT fk_engagements_task_statuses
        SQL
        execute <<-SQL
          ALTER TABLE groups
            DROP CONSTRAINT fk_groups_creators
        SQL
        execute <<-SQL
          ALTER TABLE moods
            DROP CONSTRAINT fk_moods_participants
        SQL
        execute <<-SQL
          ALTER TABLE participant_login_events
            DROP CONSTRAINT fk_login_events_participants
        SQL
        execute <<-SQL
          ALTER TABLE slideshow_anchors
            DROP CONSTRAINT fk_slideshows_anchors
        SQL
        execute <<-SQL
          ALTER TABLE task_statuses
            DROP CONSTRAINT fk_task_statuses_memberships
        SQL
        execute <<-SQL
          ALTER TABLE task_statuses
            DROP CONSTRAINT fk_tasks_statuses
        SQL
        execute <<-SQL
          ALTER TABLE tasks
            DROP CONSTRAINT fk_tasks_groups
        SQL
        execute <<-SQL
          ALTER TABLE tasks
            DROP CONSTRAINT fk_tasks_modules
        SQL
      end
    end
  end
end
