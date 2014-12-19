class Category < ActiveRecord::Base
  
    # has_many :questions, :dependent => :destroy, :order => :id
    
    has_many :category_questions, :dependent => :destroy
    has_many :questions, through: :category_questions
    
    default_scope ->  { order("title ASC") }
    
    scope :in_app, -> { where(is_iap: true) }
    scope :not_in_app, -> { where(is_iap: false) }
    scope :typo3, -> {where(old_type: 'typo3')}
    scope :kquest, -> {where(old_type: ['set','cat'])}
    
    STATUS = [['', -1], ['Basic', '0'], ['Advanced', '1'], ['Professional', '2']]
    
    def self.updated_since(date, app_name)
      logger.info("updated_since #{date}")
      Category.in_app.find(:all, :conditions => ["updated_at > :date AND app_name = :app_name", {:date => date, :app_name => app_name} ])
    end 
    
    def in_app_category
      Category.in_app.find(:first, :conditions => ["old_type = :old_type AND old_uid = :old_uid", {old_type: self.old_type, old_uid: self.old_uid}])
    end
    
end