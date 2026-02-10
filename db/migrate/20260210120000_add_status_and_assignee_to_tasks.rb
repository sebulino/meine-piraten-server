class AddStatusAndAssigneeToTasks < ActiveRecord::Migration[8.0]
  def change
    add_column :tasks, :status, :string, default: "open"
    add_column :tasks, :assignee, :string
  end
end
