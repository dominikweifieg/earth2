class Question < ActiveRecord::Base
  has_many :answers, :dependent => :destroy, :order => :id
  belongs_to :category
end
