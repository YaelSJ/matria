class CasesController < ApplicationController
  before_action :set_case, only: %i[show edit update submit_for_review decide start_review]

  def show
    authorize @case
  end

  def edit
    authorize @case
  end

  def update
    authorize @case

    unless @case.update(case_params)
      render :edit, status: :unprocessable_entity
      return
    end

    update_user_details
    redirect_to case_path(@case), notice: "Los cambios se guardaron como borrador."
  end

  def submit_for_review
    authorize @case, :update?
    @case.submit_for_review!(actor: current_user)
    redirect_to dashboard_path, notice: "Tu caso fue enviado para revisión."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to case_path(@case), alert: e.message
  end

  def assign
    case_record = policy_scope(Case).find(params[:id])

    Case.transaction do
      case_record.lock!

      authorize case_record, :show?

      raise Pundit::NotAuthorizedError unless current_user.representative? || current_user.admin?

      if case_record.representative_id.present?
        redirect_to dashboard_path(tab: "state"),
                    alert: "Este caso ya fue asignado a otra representante."
        return
      end

      authorize case_record, :assign?
      case_record.assign_to!(current_user)
    end

    redirect_to dashboard_path(tab: "assigned"),
                notice: "El caso fue asignado a ti."
  end

  def decide
    authorize @case, :decide?
    @case.decide!(current_user, params.require(:decision), comment: params[:comment])
    redirect_to case_path(@case), notice: "La decisión fue registrada."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to case_path(@case), alert: e.message
  end

  def start_review
    authorize @case, :start_review?
    @case.start_review!(current_user)
    redirect_to case_path(@case), notice: "La revisión del caso comenzó."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to case_path(@case), alert: e.message
  end

  private

  def set_case
    @case = policy_scope(Case).find(params[:id])
  end

  def case_params
    params.require(:case).permit(:content, :consent, :opening_testimony_transcript)
  end

  def update_user_details
    details = params[:user]&.permit(
      :name, :last_name, :state, :city, :phone_number,
      :user_country, :birth_date, :gender, :sex
    )
    current_user.update!(details) if details.present?

    transcript = case_params[:opening_testimony_transcript]
    return if transcript.nil? || @case.opening_testimony.nil?

    @case.opening_testimony.update!(transcript: transcript)
  end
end
