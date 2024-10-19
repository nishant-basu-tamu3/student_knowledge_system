# frozen_string_literal: true

# Application Controller class
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  protect_from_forgery with: :exception

  include Passwordless::ControllerHelpers

  helper_method :current_user
  before_action :redirect_authenticated_user

  private

  def current_user
    # puts "User: #{User.inspect}"
    @current_user ||= authenticate_by_session(User)
  end

  def require_user!
    return if current_user

    redirect_to users.sign_in_path, alert: 'Please sign in to view this content'
  end

  def redirect_authenticated_user
    return if request.path == users.sign_out_path

    redirect_to home_path if current_user && request.path == root_path
  end
end
