class DashboardsController < ApplicationController
  def show
    if current_user.user?
      @case = policy_scope(Case).first
      authorize @case, :show? if @case
    elsif current_user.representative? || current_user.admin?
      build_representative_dashboard
    else
      head :forbidden
    end
  end

  def dismiss_activity
    event = CaseEvent
            .where(case_id: policy_scope(Case).select(:id))
            .find(params[:id])

    ActivityDismissal.find_or_create_by!(
      user: current_user,
      case_event: event
    )

    redirect_back fallback_location: dashboard_path
  end

  private

  def build_representative_dashboard
    available_cases = policy_scope(Case).includes(:user, :representative)

    # Casos aún activos en la atención estatal.
    @active_state_cases = available_cases.where(
      status: %w[pending_review in_review changes_requested]
    )

    # Total de casos aprobados del estado.
    @approved_cases_count = available_cases.approved.count

    # Urgentes: riesgo alto/crítico, sin asignar o asignados que siguen pendientes.
    @urgent_cases_count = @active_state_cases
                          .where(risk_level: %w[high extreme])
                          .where(
                            "representative_id IS NULL OR status = ?",
                            "pending_review"
                          )
                          .count

    # Pendientes: todos los riesgos, sin representante y pendientes/observados.
    @pending_cases_count = available_cases
                           .where(representative_id: nil)
                           .where(status: %w[pending_review changes_requested])
                           .count

    # Filtros de la tabla “Mis casos”.
    @case_scope = params[:case_scope] == "unassigned" ? "unassigned" : "assigned"

    @selected_risk = if %w[low moderate high extreme].include?(params[:risk])
                       params[:risk]
                     end

    @case_order = params[:case_order] == "newest" ? "newest" : "oldest"

    @cases = if @case_scope == "unassigned"
               @active_state_cases.where(representative_id: nil)
             else
               @active_state_cases.where(representative_id: current_user.id)
             end

    @cases = @cases.where(risk_level: @selected_risk) if @selected_risk.present?

    @cases = if @case_order == "newest"
               @cases.order(created_at: :desc)
             else
               @cases.order(created_at: :asc)
             end

    # Filtros de actividad reciente.
    @activity_scope = params[:activity_scope] == "unassigned" ? "unassigned" : "assigned"
    @activity_order = params[:activity_order] == "oldest" ? "oldest" : "newest"

    activity_cases = if @activity_scope == "unassigned"
                       @active_state_cases.where(representative_id: nil)
                     else
                       @active_state_cases.where(representative_id: current_user.id)
                     end

    hidden_activity_ids = ActivityDismissal
                          .where(user: current_user)
                          .select(:case_event_id)

    @recent_activity = CaseEvent
                       .where(case_id: activity_cases.select(:id))
                       .where.not(id: hidden_activity_ids)
                       .includes(:case, :user)
                       .order(created_at: @activity_order == "oldest" ? :asc : :desc)
  end
end
