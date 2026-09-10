class CaseFilesController < ApplicationController

  def create
    @case = current_user.cases.find(params[:case_id])
    # @case_file =

  end
end
