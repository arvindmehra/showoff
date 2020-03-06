require 'rest-client'

class WidgetsController < ApplicationController
  before_action :user_signed_in?, except: [:index]
  def index
    response = RestClient.get("#{API_URL}/#{API_PATH}/widgets/visible",
    {params:  {client_id: CLIENT_ID, client_secret: CLIENT_SECRET}, term: 'a'})
    widgets_json = JSON.parse response.body
    @widgets = widgets_json["data"]["widgets"]
    if user_signed_in?
      response = RestClient.get("#{API_URL}/#{API_PATH}/widgets/", {:Authorization => "Bearer #{current_user_token}"})
      widgets_json = JSON.parse response.body
      @user_widgets = widgets_json["data"]["widgets"]
    end
  end

  def new
    @widget = Widget.new
  end

  def edit
    @widget = Widget.new(id: widget_params[:id],name: widget_params[:name], description: widget_params[:description], kind: widget_params[:kind])
  end

  def update
    id = params[:id]
    widget_name = widget_params[:name]
    description = widget_params[:description]
    if id.present? && widget_name.present? && description.present?
      response = RestClient.put("#{API_URL}/#{API_PATH}/widgets/#{id}",
                  {:widget=>{name: widget_name, description: description}}, {:Authorization => "Bearer #{current_user_token}"}) rescue nil
      if response.present? && response.code == 200
        widget_json = JSON.parse response.body
        @new_widget = widget_json["data"]["widget"]
        if widget_json["code"] != 0
          flash[:warning] = widget_json["message"]
          redirect_to new_widget_path
        else
          flash[:success] = "Congratulations Your new widget have been Updated!!"
          redirect_to user_path(@new_widget["user"]["id"])
        end
      else
        flash[:warning] = "Please check your informations, this widget might already be updated"
        redirect_to new_widget_path
      end
    else
      flash[:warning] = "Please fill all informations"
      redirect_to new_widget_path
    end
  end

  def create
    if widget_params[:name].present? && widget_params[:description].present? && widget_params[:kind].present?
       response = RestClient.post("#{API_URL}/#{API_PATH}/widgets",
                  {:widget=>{name: widget_params[:name], description: widget_params[:description], kind: widget_params[:kind]}}, {:Authorization => "Bearer #{current_user_token}"}) rescue nil
      if response.present? && response.code == 200
        widget_json = JSON.parse response.body
        @new_widget = widget_json["data"]["widget"]
        if widget_json["code"] != 0
          flash[:warning] = widget_json["message"]
          redirect_to new_widget_path
        else
          flash[:success] = "Congratulations Your new widget have been created!!"
          redirect_to user_path(@new_widget["user"]["id"])
        end
      else
        flash[:warning] = "Please check your informations, this widget might already be present"
        redirect_to new_widget_path
      end
    else
      flash[:warning] = "Please fill all informations"
      redirect_to new_widget_path
    end
  end

  def destroy
    widget = params[:id]
    if widget.present?
      response = RestClient.delete("#{API_URL}/#{API_PATH}/widgets/#{widget}",
                  {:Authorization => "Bearer #{current_user_token}"}) rescue nil
      if response.present? && response.code == 200
        flash[:success] = "Congratulations Your widget have been deleted!!"
      else
        flash[:danger] = "Oops Your widget could not be deleted!!"
      end
      redirect_to root_path
    else
      flash[:danger] = "Oops Your widget could not be deleted!!"
      redirect_to root_path
    end
  end

  private
    def widget_params
      params.fetch(:widget, {}).permit(:name,:description,:kind, :id)
    end

end
