class KquestCategory < ActiveRecord::Base
  establish_connection :kquest
  
  self.table_name = "category"
  self.primary_key = "cid"
  self.inheritance_column = ""
  
  default_scope order('cat_title ASC')
  
  has_many :kquest_category_questions, :foreign_key => :catId
  has_many :kquest_questions, :through => :kquest_category_questions
end
