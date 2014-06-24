class Category < ActiveRecord::Base
  
    has_many :questions, :dependent => :destroy, :order => :id
    
    default_scope order("title ASC")
    
    STATUS = [['', -1], ['Basic', '0'], ['Advanced', '1'], ['Professional', '2']]
    
    def self.updated_since(date, app_name)
      logger.info("updated_since #{date}")
      Category.find(:all, :conditions => ["updated_at > :date AND app_name = :app_name", {:date => date, :app_name => app_name} ])
    end 
    
end