class AppsController < ApplicationController
  before_action :authenticate_user!
  def index
    apps_raw = Category.in_app.pluck('DISTINCT app_name')
    set = Set.new
    apps_raw.each do |raw| 
      split = raw.split(",")
      split.each {|part| set << part}
    end
    @apps = Array.new()
    set.each {|item| @apps << item}
  end
  
  def show
    @categories = Category.in_app.app_name(params[:id])
    @app_name = params[:id]
    respond_to do |format|
      format.html {}
      format.js {}
    end
  end
end
