class AddMissingConstraints < ActiveRecord::Migration
  def change
    BitPlayer::ParticipantStatus.all.each do |s|
      s.destroy! if s.participant.nil?
    end
    Group.all.each do |g|
      g.update!(arm_id: nil) if g.arm.nil?
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE bit_player_participant_statuses
            ADD CONSTRAINT fk_statuses_participants
            FOREIGN KEY (participant_id)
            REFERENCES participants(id)
        SQL
        execute <<-SQL
          ALTER TABLE groups
            ADD CONSTRAINT fk_groups_arms
            FOREIGN KEY (arm_id)
            REFERENCES arms(id)
        SQL
      end

      dir.down do
        execute <<-SQL
          ALTER TABLE bit_player_participant_statuses
            DROP CONSTRAINT IF EXISTS fk_statuses_participants
        SQL
        execute <<-SQL
          ALTER TABLE groups
            DROP CONSTRAINT IF EXISTS fk_groups_arms
        SQL
      end
    end

    change_column_null :arms, :has_woz, false
    change_column_null :emotional_ratings, :rating, false
    change_column_null :moods, :rating, false
    change_column_null :participant_login_events, :participant_id, false
  end
end
