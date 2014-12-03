# This migration comes from think_feel_do_engine (originally 20140418190852)
class RemoveFkGroupsUsersConstraint < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER TABLE groups
        DROP CONSTRAINT fk_groups_users
    SQL

    change_column_null :groups, :creator_id, true
  end

  def down
    change_column_null :groups, :creator_id, false

    execute <<-SQL
      ALTER TABLE groups
        ADD CONSTRAINT fk_groups_users
        FOREIGN KEY (creator_id)
        REFERENCES users(id)
    SQL
  end
end
