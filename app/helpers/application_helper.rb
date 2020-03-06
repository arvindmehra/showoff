module ApplicationHelper

  def user_signed_in?
    session[:user_id].present?
  end

  def current_user_token
    user_signed_in? ? session[:user_id] : nil
  end

end
