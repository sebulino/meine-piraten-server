json.extract! task, :id, :title, :description, :completed, :creator_name, :time_needed_in_hours, :activity_points, :category_id, :entity_id, :created_at, :updated_at
json.url task_url(task, format: :json)
