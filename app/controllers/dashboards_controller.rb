class DashboardsController < ApplicationController
  def show
    if current_user.user?
      @case = policy_scope(Case).first
      authorize @case, :show? if @case
    elsif current_user.representative?
      @state_cases = policy_scope(Case)
                     .includes(:representative)
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
