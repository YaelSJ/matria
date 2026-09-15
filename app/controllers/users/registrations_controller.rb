module Users
  class RegistrationsController < Devise::RegistrationsController
    protected

    def after_sign_up_path_for(resource)
      flash.delete(:notice)
      flash[:registration_success] = true
      new_case_case_file_path(resource.case)
    end
  end
end
