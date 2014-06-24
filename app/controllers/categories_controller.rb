class CategoriesController < ApplicationController
  require 'imobile'
  
  before_action :set_category, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:show, :index, :fetch, :initial]
  before_action :check_access

  # GET /categories
  # GET /categories.json
  def index
    app_name = params[:app_name]
    app_name = "iKreawi" unless app_name
    if params[:updated_after].present?
      @categories = Category.updated_since(params[:updated_after], app_name)
      @token = daily_token
    elsif params[:original_questions].present?
      @categories = Category.find(:all, :conditions => ["original_pruefung = :original_pruefung AND app_name = :app_name", {:original_pruefung => params[:original_questions], :app_name => app_name}])
    elsif params[:type_id].present?
      @categories = Category.find(:all, :conditions => ["type_id = :type_id AND app_name = :app_name", {:type_id => params[:type_id], :app_name => app_name}])
    else
      case request.format
      when Mime::JSON
        @categories = Category.find(:all, :conditions => ["app_name = :app_name", {:app_name => app_name}])
      else
        @categories = Category.all
      end
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @categories }
      format.plist
      format.json
    end
  end

  # GET /categories/1
  # GET /categories/1.json
  def show
  end

  # GET /categories/new
  def new
    @category = Category.new
  end

  # GET /categories/1/edit
  def edit
  end

  # POST /categories
  # POST /categories.json
  def create
    @category = Category.new(category_params)

    respond_to do |format|
      if @category.save
        format.html { redirect_to @category, notice: 'Category was successfully created.' }
        format.json { render action: 'show', status: :created, location: @category }
      else
        format.html { render action: 'new' }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /categories/1
  # PATCH/PUT /categories/1.json
  def update
    respond_to do |format|
      if @category.update(category_params)
        format.html { redirect_to @category, notice: 'Category was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.json
  def destroy
    @category.destroy
    respond_to do |format|
      format.html { redirect_to categories_url }
      format.json { head :no_content }
    end
  end
  
  def initial
    app_name = params[:app_name]
    app_name = "iKreawi" unless app_name
    @category = Category.find(:first, :conditions => ["original_pruefung = :original_pruefung AND app_name = :app_name", {:original_pruefung => true, :app_name => app_name}], :order => "created_at DESC")
    render :text => @category.identifier
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = Category.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def category_params
      params.require(:category).permit(:title, :short_title, :description, :identifier, :old_uid, :app_name, :area, :original_pruefung, :type_id)
    end
    
    def check_itunes_receipt(receipt)
      if(params[:sandbox].present?)
        @receipt = Imobile.validate_receipt(receipt, :sandbox)
      else
        @receipt = Imobile.validate_receipt(receipt, :production)
      end
      logger.info "receipt: #{@receipt}"
      @receipt
    end
  
    def daily_token
      Date.new.to_s.hash.to_s(36)
    end
    
    def check_access
      respond_to do |format|
        format.html do
          user_signed_in?
        end
        format.xml do 
          #logged_in? unless request.headers["producer"] == "android"
        end
        format.json do
          #OK
        end
        format.plist do
          if params[:transaction_receipt].present?
            check_itunes_receipt params[:transaction_receipt]
          elsif params[:initial].present?
            #OK
          elsif params[:token].present? && params[:token] == daily_token
            #OK
          elsif params[:updated_after].present?
            #OK
          elsif params[:original_questions].present?
            #OK
          elsif params[:type_id].present?
            #OK
          else
            render :text => "Not authorized"
          end
        end
      end
    end
end
