class AddPatternIdToThoughts < ActiveRecord::Migration
  def change
    add_column :thoughts, :pattern_id, :integer

    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE thoughts
            ADD CONSTRAINT fk_thoughts_patterns
            FOREIGN KEY (pattern_id)
            REFERENCES thought_patterns(id)
        SQL
      end
      dir.down do
        execute <<-SQL
          ALTER TABLE thoughts
            DROP CONSTRAINT fk_thoughts_patterns
        SQL
      end
    end
  end
end
