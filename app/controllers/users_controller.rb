require 'rest-client'
class UsersController < ApplicationController
  def show
    if user_signed_in?
      response = RestClient.get("#{API_URL}/users/#{params[:id]}",{:Authorization => "Bearer #{current_user_token}"})
      user_json = JSON.parse response.body
      @user = user_json["data"]["user"]
      response = RestClient.get("#{API_URL}/users/#{params[:id]}/widgets",
      {params: {client_id: CLIENT_ID, client_secret: CLIENT_SECRET},:Authorization => "Bearer #{current_user_token}"})
      user_widgets = JSON.parse response.body
      @user_widgets = user_widgets["data"]["widgets"]
    else
      flash[:warning] = "Please Login to see widgets' owner!!"
      redirect_to root_path
    end
  end

  def register
    session.clear
    first_name= params[:first_name]
    last_name = params[:last_name]
    password = params[:password]
    email = params[:email]
    if first_name.present? && last_name.present? && password.present? && email.present?
      url = "#{API_URL}/users"
      payload = {client_id: CLIENT_ID, client_secret: CLIENT_SECRET,
                                        :user=>{:first_name=>first_name, :last_name=>last_name, :password=>password,
                                        :email=>email, :image_url=>"https://static.thenounproject.com/png/961-200.png"}}
      response = nil
      response = RestClient.post(url, payload) rescue nil

      if response.present? && response.code == 200
        user_json = JSON.parse response.body
        user_data = user_json["data"]
        token = user_data["token"]["access_token"]
        session[:user_id] = token
      end
    end
    if session[:user_id].present?
      flash[:success] = "Yay! Your account has been created!!"
    else
      flash[:danger] = "Oops your account could not created!!"
    end
    redirect_to root_path
  end

  def logout
    response = RestClient.post("https://showoff-rails-react-production.herokuapp.com/oauth/revoke",
      {token: current_user_token}, {:Authorization => "Bearer #{current_user_token}"})
    session.clear
    flash[:success] = "You have been successfully logged out"
    redirect_to root_path
  end

  def sign_in
    password = params[:password]
    email = params[:email]
   if password.present? && email.present?
      url = "https://showoff-rails-react-production.herokuapp.com/oauth/token"
      payload = {client_id: CLIENT_ID, client_secret: CLIENT_SECRET,:password=>password,
                                        :username=>email, :grant_type=>"password" }
      response = nil
      response = RestClient.post(url, payload) rescue nil

      if response.present? && response.code == 200
        user_json = JSON.parse response.body
        user_data = user_json["data"]
        token = user_data["token"]["access_token"]
        session[:user_id] = token
      end
    end
    if session[:user_id].present?
      flash[:success] = "Yay! You have succesfully logged in!"
    else
      flash[:danger] = "Oops can't login please check your credentials again!!"
    end
    redirect_to root_path
  end

  def reset_password
    email = params[:email]
    if email.present?
      url = "https://showoff-rails-react-production.herokuapp.com/api/v1/users/reset_password"
      payload = {:user=>{:email=>email},client_id: CLIENT_ID, client_secret: CLIENT_SECRET}
      response = nil
      response = RestClient.post(url, payload) rescue nil
      if response.present? && response.code == 200
        user_json = JSON.parse response.body
        if user_json["code"] == 0
          flash[:success] = user_json["message"]
        end
      else
        flash[:danger] = "Could not reset your password, Please check your email address"
      end
    end
    redirect_to root_path
  end

end



