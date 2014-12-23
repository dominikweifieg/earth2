class Question < ActiveRecord::Base
  has_many :answers, -> {order(:id)}, :dependent => :destroy
  
  has_many :category_questions, :dependent => :destroy
  has_many :categories, through: :category_questions
  
  scope :typo3, ->(uid) {where("old_type = 'typo3' AND old_uid = ?", uid)}
  scope :kquest_set, ->(uid) {where("old_type = 'set' AND old_uid = ?", uid)}
  scope :kquest_cat, ->(uid) {where("old_type = 'cat' AND old_uid = ?", uid)}
  def in_app_category
    self.categories.in_app.first()
  end
  
  def import_category
    self.categories.not_in_app.first()
  end
end
