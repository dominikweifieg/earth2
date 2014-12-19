class Question < ActiveRecord::Base
  has_many :answers, :dependent => :destroy, :order => :id
  
  has_many :category_questions, :dependent => :destroy
  has_many :categories, through: :category_questions
  
  def in_app_category
    self.categories.first(conditions: {is_iap: true})
  end
  
  def import_category
    self.categories.first(conditions: {is_iap: false})
  end
end
