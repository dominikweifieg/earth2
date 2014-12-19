class AppsController < ApplicationController
  before_action :authenticate_user!
  def index
    @apps = Category.in_app.pluck('DISTINCT app_name')
  end
  
  def show
    @categories = Category.in_app.find_all_by_app_name(params[:id])
    @app_name = params[:id]
    respond_to do |format|
      format.html {}
      format.js {}
    end
  end
end
