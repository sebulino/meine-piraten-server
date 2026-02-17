class CommentsController < ApplicationController
  before_action :set_task
  before_action :require_admin!, only: [:destroy]

  # GET /tasks/:task_id/comments.json
  def index
    @comments = @task.comments.order(created_at: :asc)
  end

  # POST /tasks/:task_id/comments.json
  def create
    @comment = @task.comments.build(comment_params)

    respond_to do |format|
      if @comment.save
        format.json { render partial: "comments/comment", locals: { comment: @comment }, status: :created }
      else
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/:task_id/comments/:id.json
  def destroy
    @comment = @task.comments.find(params.expect(:id))
    @comment.destroy!

    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private

  def set_task
    @task = Task.find(params.expect(:task_id))
  end

  def comment_params
    params.expect(comment: [ :author_name, :text ])
  end
end
