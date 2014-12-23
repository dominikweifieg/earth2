class Question < ActiveRecord::Base
  has_many :answers, -> {order(:id)}, :dependent => :destroy
  
  has_many :category_questions, :dependent => :destroy
  has_many :categories, through: :category_questions
  
  def in_app_category
    self.categories.in_app.first()
  end
  
  def import_category
    self.categories.not_in_app.first()
  end
end
