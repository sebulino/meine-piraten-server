class AdminRequestsController < ApplicationController
  before_action :require_superadmin!, only: [:index, :approve, :reject]

  def index
    @pending_requests = AdminRequest.pending.includes(:user).order(created_at: :desc)
    @reviewed_requests = AdminRequest.where(status: %w[approved rejected]).includes(:user, :reviewed_by).order(reviewed_at: :desc)
  end

  def create
    @admin_request = current_user_or_api_user.admin_requests.new(reason: params[:reason])

    if @admin_request.save
      render :create, formats: [:json], status: :created
    else
      render json: { errors: @admin_request.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def approve
    @admin_request = AdminRequest.find(params[:id])
    @admin_request.update!(status: "approved", reviewed_by: current_user_or_api_user, reviewed_at: Time.current)
    @admin_request.user.update!(admin: true)

    respond_to do |format|
      format.html { redirect_to admin_requests_path, notice: "Anfrage genehmigt. #{@admin_request.user.preferred_username || @admin_request.user.name} ist jetzt Admin." }
      format.json { render json: { status: "approved" } }
    end
  end

  def reject
    @admin_request = AdminRequest.find(params[:id])
    @admin_request.update!(status: "rejected", reviewed_by: current_user_or_api_user, reviewed_at: Time.current)

    respond_to do |format|
      format.html { redirect_to admin_requests_path, notice: "Anfrage abgelehnt." }
      format.json { render json: { status: "rejected" } }
    end
  end
end
