class Category < ActiveRecord::Base
  
    # has_many :questions, :dependent => :destroy, :order => :id
    validates :identifier, :title, :short_title, presence: true
    validates :identifier, uniqueness: true 
    
    
    has_many :category_questions, :dependent => :destroy
    has_many :questions, through: :category_questions
    
    default_scope ->  { order("title ASC") }
    
    scope :in_app, -> { where(is_iap: true) }
    scope :not_in_app, -> { where(is_iap: false) }
    scope :typo3, -> {where(old_type: 'typo3', is_iap: false)}
    scope :kquest, -> {where(old_type: ['set','cat'])}
    scope :app_name, ->(app_name) {where("app_name LIKE ?", "%#{app_name}%")}
    scope :by_type_and_uid, ->(type, uid) {where(old_type: type, old_uid: uid)}
    
    STATUS = [['', -1], ['Basic', '0'], ['Advanced', '1'], ['Professional', '2']]
    
    @@APP_NAMES = ['iKreawi','Medizinfragen','Anatomie','Physiologie']
    @@AREAS = ['Krankenpfleger/-in','Physiotherapeut/-in','Rettungsassistent/-in','Hebamme','Altenpflege','Pharmareferent','Arzthelfer/-in','Medizinstudent']
    
      def self.app_names 
        @@APP_NAMES
      end
    
      def self.areas 
        @@AREAS
      end
    
    def self.updated_since(date, app_name)
      logger.info("updated_since #{date}")
      Category.in_app.find(:all, :conditions => ["updated_at > :date AND app_name = :app_name", {:date => date, :app_name => app_name} ])
    end 
    
    def in_app_categories
      Category.in_app.by_type_and_uid(self.old_type, self.old_uid)
    end
    
end