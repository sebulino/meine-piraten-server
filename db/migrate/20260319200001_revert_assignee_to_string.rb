class RevertAssigneeToString < ActiveRecord::Migration[8.1]
  def up
    add_column :tasks, :assignee, :string

    # Migrate assignee_id → assignee (preferred_username)
    execute <<~SQL
      UPDATE tasks
      SET assignee = (
        SELECT users.preferred_username
        FROM users
        WHERE users.id = tasks.assignee_id
      )
      WHERE tasks.assignee_id IS NOT NULL
    SQL

    remove_foreign_key :tasks, column: :assignee_id
    remove_index :tasks, :assignee_id
    remove_column :tasks, :assignee_id
  end

  def down
    add_column :tasks, :assignee_id, :integer
    add_index :tasks, :assignee_id
    add_foreign_key :tasks, :users, column: :assignee_id

    execute <<~SQL
      UPDATE tasks
      SET assignee_id = (
        SELECT users.id
        FROM users
        WHERE users.preferred_username = tasks.assignee
      )
      WHERE tasks.assignee IS NOT NULL
    SQL

    remove_column :tasks, :assignee
  end
end
