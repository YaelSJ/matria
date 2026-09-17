module Users
  class SessionsController < Devise::SessionsController
    def create
      super do |_resource|
        flash.delete(:notice)
        flash[:login_welcome] = true
      end
    end
  end
end
