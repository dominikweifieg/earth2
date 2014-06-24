class AppsController < ApplicationController
  before_action :authenticate_user!
  def index
    @apps = Category.pluck('DISTINCT app_name')
  end
  
  def show
    @categories = Category.find_all_by_app_name(params[:id])
    @app_name = params[:id]
  end
end
