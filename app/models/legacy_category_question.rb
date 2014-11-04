class LegacyCategoryQuestion < ActiveRecord::Base
  establish_connection :legacy 
  self.table_name = "tx_wintestsuite_questions_category_mm"
  self.inheritance_column = ""
  
  belongs_to :legacy_category, :foreign_key => :uid_foreign, :primary_key => :uid
  belongs_to :legacy_question, :foreign_key => :uid_local, :primary_key => :uid
end
