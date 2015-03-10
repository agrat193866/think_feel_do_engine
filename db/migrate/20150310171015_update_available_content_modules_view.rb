class UpdateAvailableContentModulesView < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        execute <<-SQL
          create or replace view available_content_modules as (
            select tasks.bit_core_content_module_id as id,
                   tasks.has_didactic_content,
                   bit_core_content_modules.bit_core_tool_id,
                   bit_core_content_modules.is_viz,
                   bit_core_content_modules.position,
                   bit_core_content_modules.title,
                   assigned_tasks.membership_id,
                   assigned_tasks.id as task_status_id,
                   assigned_tasks.participant_id,
                   assigned_tasks.available_on,
                   assigned_tasks.completed_at,
                   assigned_tasks.membership_start_date + tasks.termination_day - 1 as terminates_on
            from tasks
              inner join (
                  select memberships.id as membership_id,
                         memberships.start_date as membership_start_date,
                         memberships.participant_id,
                         task_statuses.id,
                         task_statuses.task_id,
                         case when memberships.is_complete then memberships.start_date
                           else memberships.start_date + task_statuses.start_day - 1
                         end as available_on,
                         task_statuses.completed_at
                  from task_statuses
                    inner join memberships
                      on task_statuses.membership_id = memberships.id
                ) as assigned_tasks
                on tasks.id = assigned_tasks.task_id
              inner join bit_core_content_modules
                on tasks.bit_core_content_module_id = bit_core_content_modules.id
            )
        SQL
      end

      dir.down do
        execute <<-SQL
          drop view if exists available_content_modules
        SQL
      end
    end
  end
end
