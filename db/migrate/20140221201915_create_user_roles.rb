class CreateUserRoles < ActiveRecord::Migration
  def change
    create_table :user_roles do |t|
      t.references :user, index: true, null: false
      t.string :role_class_name, null: false

      t.timestamps
    end

    add_index :user_roles, [:role_class_name, :user_id], unique: true

    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE user_roles
            ADD CONSTRAINT fk_roles_users
            FOREIGN KEY (user_id)
            REFERENCES users(id)
        SQL
      end
    end
  end
end
