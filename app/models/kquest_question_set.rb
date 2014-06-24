class KquestQuestionSet < ActiveRecord::Base
  establish_connection :kquest
  
  self.table_name = "fragenset"
  self.primary_key = "set_id"
  self.inheritance_column = ""
  
  default_scope order('set_name ASC')
  
  has_many :kquest_links, :foreign_key => :setID
  has_many :kquest_questions, :through => :kquest_links
end
