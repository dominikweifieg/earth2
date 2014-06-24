class KquestCategoryQuestion < ActiveRecord::Base
  establish_connection :kquest 
  self.table_name = "questcat"
  self.inheritance_column = ""
  
  belongs_to :kquest_category, :foreign_key => :catID, :primary_key => :cid
  belongs_to :kquest_question, :foreign_key => :questID, :primary_key => :uid
end