class DashboardsController < ApplicationController
  def show
    if current_user.user?
      @case = policy_scope(Case).first
      authorize @case, :show? if @case
    elsif current_user.representative? || current_user.admin?
      @state_cases = policy_scope(Case)
                     .includes(:representative)
                     .where(status: %i[pending_review in_review changes_requested])
                     .in_order_of(:risk_level, %w[critical high medium low])

      @assigned_cases = @state_cases.where(
        representative_id: current_user.id
      )
      @active_tab = params[:tab] == "state" ? "state" : "assigned"

      @cases = if @active_tab == "state"
                 @state_cases
               else
                 @assigned_cases
               end
    else
      head :forbidden
    end
  end
end
