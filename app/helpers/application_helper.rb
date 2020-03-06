module ApplicationHelper

  def user_signed_in?
    session[:user_token].present?
  end

  def current_user_token
    session[:user_token]
  end

  def current_user_id
    session[:user_id]
  end

  def current_user_name
    session[:user_name]
  end

end
