module Users
  class RegistrationsController < Devise::RegistrationsController
    protected

    def after_sign_up_path_for(resource)
      new_case_case_file_path(resource.case)
    end
  end
end
