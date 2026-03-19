class ChangeTaskAssigneeToUserReference < ActiveRecord::Migration[8.1]
  def up
    add_reference :tasks, :assignee, foreign_key: { to_table: :users }, null: true

    # Migrate existing string assignees to user references where possible
    execute <<-SQL
      UPDATE tasks
      SET assignee_id = (
        SELECT users.id FROM users
        WHERE users.preferred_username = tasks.assignee
        LIMIT 1
      )
      WHERE tasks.assignee IS NOT NULL AND tasks.assignee != ''
    SQL

    remove_column :tasks, :assignee, :string
  end

  def down
    add_column :tasks, :assignee, :string

    execute <<-SQL
      UPDATE tasks
      SET assignee = (
        SELECT users.preferred_username FROM users
        WHERE users.id = tasks.assignee_id
        LIMIT 1
      )
      WHERE tasks.assignee_id IS NOT NULL
    SQL

    remove_reference :tasks, :assignee
  end
end
