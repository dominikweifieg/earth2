class KquestQuestion < ActiveRecord::Base
  establish_connection :kquest 
  self.table_name = "questions"
  self.primary_key = "uid"
  self.inheritance_column = ""
  
  default_scope { where(:deleted => 0) }
  
  has_many :kquest_links, :foreign_key => "questID"
  has_many :kquest_question_sets, :through => :kquest_links
  has_many :kquest_category_questions, :foreign_key => "questID"
  has_many :kquest_categories, :through => :kquest_category_questions
  
  def primary_key
    "uid"
  end
  
  def to_param
    "#{uid}"
  end
end