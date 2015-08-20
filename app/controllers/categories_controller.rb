class CategoriesController < ApplicationController
  require 'imobile'
  
  before_action :set_category, only: [:edit, :update, :destroy, :itunesconnect]
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
        @categories = Category.not_in_app.kquest.all
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
    
    if @receipt
      product_id = @receipt[:product_id]
      logger.info("We have a receipt and the product_id is #{product_id}")
      product_id = product_id.sub(/medizinfragen\./, "")
      @category = Category.find_by_identifier(product_id)
    elsif params[:product_id].present?
      product_id = params[:product_id]
      logger.info("We have a product_id which is #{product_id}")
      product_id = product_id.sub(/medizinfragen\./, "")
      logger.info("product_id = #{product_id}")
      @category = Category.find_by_identifier(product_id)
    else
      logger.info("looking up the category by id #{params[:id]}")
      @category = Category.find(params[:id])
    end
    
    logger.info("Category is #{@category.identifier}, creation date: #{@category.created_at} #{@category.created_at.class}")
    
    respond_to do |format|
      format.html {}
      format.js {  headers['Content-Type'] = 'text/javascript' }
      format.plist 
      format.xml
      format.json { render :json => @category.to_json(:include => {:questions => {:include => :answers }})}
    end
  end

  # GET /categories/new
  def new
    @category = Category.new
    if params[:commit] == "addieren"
      @category = Category.find_by_id(params[:existing_in_app])
      @selected_questions ||= params[:questions].keys.join("_")
      @existing_in_app = params[:existing_in_app]
    elsif params[:id].present?
      @source_category = Category.find_by_id(params[:id])
      @category.title = @source_category.title
      @category.short_title = @source_category.short_title
      @category.description = "Created from #{@source_category.title} (KQuest #{@source_category.old_type}:#{@source_category.old_uid})"
      @category.old_type = @source_category.old_type
      @category.old_uid = @source_category.old_uid
      @category.app_name = @source_category.app_name
      @category.area = @source_category.area
      @category.original_pruefung = @source_category.original_pruefung
      @category.type_id = @source_category.type_id
      @category.identifier = "de.kreawi.mobile.#{@source_category.title.parameterize('_')}.iap".sub(/-/, "_")
    elsif params[:questions].present?
      logger.info("New Selected questions = #{@selected_questions}")
      @selected_questions ||= params[:questions].keys.join("_")
      first_question = Question.find_by_id(params[:questions].keys.first)
      @source_category = first_question.import_category
      @category.title = @source_category.title
      @category.short_title = @source_category.short_title
      @category.description = "Created from #{@source_category.title} (Typo3 Katgorie:#{@source_category.old_uid})"
      @category.old_type = @source_category.old_type
      @category.old_uid = @source_category.old_uid
      @category.app_name = "iKreawi"
      @category.area = ""
      @category.original_pruefung = @source_category.original_pruefung
      @category.type_id = @source_category.type_id
      @category.identifier = "de.kreawi.mobile.#{@source_category.title.parameterize('_')}.iap".sub(/-/, "_")
    end
  end

  # GET /categories/1/edit
  def edit
  end

  # POST /categories
  # POST /categories.json
  def create
    if params[:existing_in_app].present?
      @category = Category.find_by_id(params[:existing_in_app])
    else 
      @category = Category.new(category_params)
    end 
    if params[:selected_questions].present?
      @selected_questions = params[:selected_questions]
      logger.info("Create Selected questions = #{@selected_questions}")
      questIds = params[:selected_questions].split("_")
      questions = Question.find(questIds)
      @category.questions = questions
      @category.is_iap = true
    elsif params[:source_category].present?
        @source_category = Category.find_by_id(params[:source_category])
        @category.questions << @source_category.questions
        @category.is_iap = true
    end

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
    if params[:selected_questions].present?
      @selected_questions = params[:selected_questions]
      logger.info("Create Selected questions = #{@selected_questions}")
      questIds = params[:selected_questions].split("_")
      questions = Question.find(questIds)
      @category.questions << questions
    end
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
    respond_to do |format|
      format.html { 
        @category.destroy
        redirect_to categories_url 
      }
      format.json { head :no_content }
      format.js {  headers['Content-Type'] = 'text/javascript' }
    end
  end
  
  def initial
    app_name = params[:app_name]
    app_name = "iKreawi" unless app_name
    @category = Category.find(:first, :conditions => ["original_pruefung = :original_pruefung AND app_name = :app_name", {:original_pruefung => true, :app_name => app_name}], :order => "created_at DESC")
    render :text => @category.identifier
  end
  
  def itunesconnect 
    @app_name = params[:app_name]
    respond_to do |format|
      format.html { render :layout => false }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = Category.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def category_params
      params.require(:category).permit(:title, :short_title, :description, :identifier, :old_uid, :app_name, :area, :original_pruefung, :type_id, :old_type)
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
