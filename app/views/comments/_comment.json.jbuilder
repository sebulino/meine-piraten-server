json.extract! comment, :id, :task_id, :author_name, :text, :created_at, :updated_at
json.url task_comment_url(comment.task, comment, format: :json)
