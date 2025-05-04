class AddUrgencFlagToTasks < ActiveRecord::Migration[8.0]
  def change
    add_column :tasks, :is_urgent, :boolean
  end
end
