class UpdateTasksWithBitCore < ActiveRecord::Migration
  def up
    remove_index :tasks, name: :index_tasks_on_bit_player_content_module_id
    rename_column :tasks, :bit_player_content_module_id, :bit_core_content_module_id
    add_index :tasks, :bit_core_content_module_id
  end
end
