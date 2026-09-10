class CasesController < ApplicationController
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
end
