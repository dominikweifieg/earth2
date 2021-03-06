class Typo3Controller < ApplicationController
  before_action :authenticate_user!
  def index
    @categories = Category.typo3
    
    @inApps = Category.in_app
  end
  
  def show
    @category = Category.typo3.find_by_id(params[:id])
    @questions = @category.questions
    respond_to do |format|
      format.html {}
      format.js {}
    end
  end
  
  def destroy
    @category = Category.typo3.find_by_id(params[:id])
    @questions = @category.questions
    respond_to do |format|
      format.html {}
      format.js {}
    end
  end
end
