class Answer < ActiveRecord::Base
  belongs_to :question
  
  LETTERS = %W(A B C D E)
end
