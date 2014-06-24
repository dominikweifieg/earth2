class KquestLink < ActiveRecord::Base
  establish_connection :kquest 
  self.table_name = "questset"
  self.inheritance_column = ""
  
  belongs_to :kquest_question_set, :foreign_key => :setID, :primary_key => :set_id
  belongs_to :kquest_question, :foreign_key => :questID, :primary_key => :uid
end