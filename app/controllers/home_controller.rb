class HomeController < ApplicationController
  
  before_action :authenticate_user!
  
  def home
    apps = Category.pluck('DISTINCT app_name')
    if(params[:q].present?)
      apps.select!{|item| item =~ /#{params[:q]}/ }
      kquest_categories = KquestCategory.all(:conditions => ["cat_title LIKE ?", "%#{params[:q]}%"])
      kquest_sets = KquestQuestionSet.all(:conditions => ["set_active = 1 AND set_name LIKE ?", "%#{params[:q]}%"]);
    else 
      kquest_categories = KquestCategory.all
      kquest_sets = KquestQuestionSet.all(:conditions => "set_active = 1");
    end
    imported_set_uids = Category.where(old_type: "set").pluck(:old_uid)
    imported_cat_uids = Category.where(old_type: "cat").pluck(:old_uid)
    
    cat_count = kquest_categories.count
    set_count = kquest_sets.count
    app_count = apps.count
    
    max_count = cat_count
    max_count = set_count if set_count > max_count
    max_count = app_count if app_count > max_count
    
    @combined = Array.new()
    
    for i in 0..max_count do
      kcat = ""
      kcat_id = -1
      kcat_active = false
      kset = ""
      kcat_id = -1
      kset_active = false
      app = ""
      if cat_count > i
        kcat = kquest_categories[i].cat_title 
        kcat_id = kquest_categories[i].cid
        kcat_active = imported_cat_uids.include? kquest_categories[i].cid
      end
      if set_count > i
        kset = kquest_sets[i].set_name
        kset_id = kquest_sets[i].set_id
        kset_active = imported_set_uids.include? kquest_sets[i].set_id
      end
      app = apps[i] if app_count > i
      
      @combined << {kcat: kcat, kcat_id: kcat_id, kcat_active: kcat_active, kset: kset, kset_id: kset_id, kset_active: kset_active, app: app}
    end
  end
end
