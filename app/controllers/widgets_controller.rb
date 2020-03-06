require 'rest-client'

class WidgetsController < ApplicationController
  def index
    response = RestClient.get("#{API_URL}/widgets/visible",
    {params:  {client_id: CLIENT_ID, client_secret: CLIENT_SECRET}, term: 'a'})


    widgets_json = JSON.parse response.body


    @widgets = widgets_json["data"]["widgets"]
  end
end
