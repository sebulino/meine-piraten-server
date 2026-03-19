json.extract! task, :id, :title, :description, :completed, :creator_name, :time_needed_in_hours, :due_date, :urgent, :activity_points, :category_id, :entity_id, :status, :assignee_id, :created_at, :updated_at
json.assignee_name task.assignee&.name
json.url task_url(task, format: :json)
