class CasesController < ApplicationController
  before_action :set_case, only: %i[show edit update submit_for_review]

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
    @case.submit_for_review!
    redirect_to dashboard_path, notice: "Tu caso fue enviado para revisión."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to case_path(@case), alert: e.message
  end

  def assign
    case_record = Case.find(params[:id])

    Case.transaction do
      case_record.lock!

      authorize case_record, :show?

      unless current_user.representative?
        raise Pundit::NotAuthorizedError
      end

      if case_record.representative_id.present?
        redirect_to dashboard_path(tab: "state"),
                    alert: "Este caso ya fue asignado a otra representante."
        return
      end

      authorize case_record, :assign?
      case_record.update!(representative: current_user)
    end

    redirect_to dashboard_path(tab: "assigned"),
                notice: "El caso fue asignado a ti."
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
