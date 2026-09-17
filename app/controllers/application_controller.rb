class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :authenticate_user!

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def after_sign_in_path_for(resource)
    flash.delete(:notice)
    flash[:login_success] = true

    dashboard_path
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :name, :last_name, :birth_date, :gender, :sex, :state, :city, :user_country])
    devise_parameter_sanitizer.permit(:account_update, keys: [
      :name, :last_name, :birth_date, :gender, :sex, :state, :city, :user_country])
  end

  def default_url_options
    { host: ENV["DOMAIN"] || "localhost:3000" }
  end
end
