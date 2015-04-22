#encoding: utf-8

class LegacyCategory < ActiveRecord::Base
  establish_connection :legacy 
  self.table_name = "tx_wintestsuite_categories"
  self.primary_key = "uid"
  self.inheritance_column = ""
  
  has_many :legacy_category_questions, :foreign_key => :uid_foreign, :primary_key => :uid
  has_many :legacy_questions, :through => :legacy_category_questions
  
  scope :ikreawi_categories, -> {where("title LIKE 'APP_ikreawi%' AND deleted = 0 AND hidden = 0")}
  
  def primary_key
    "uid"
  end
  
  def to_param
    "#{uid}"
  end
  
  def self.import_all 
    puts "Importing all!"
    categories = LegacyCategory.ikreawi_categories
    categories.each do |lc| 
      myTitle = lc.title[12, lc.title.length]
      puts "Title: #{lc.title}, myTitle: #{myTitle}"
      puts "Title encoding: #{lc.title.encoding}"
      puts "myTitle encoding: #{myTitle.encoding}"
      category = Category.find_by_old_uid_and_old_type(lc.uid, 'typo3')
      if(category)
        # category.questions.clear
        puts "Found? #{category.title}"
        category.touch
      else
        puts "Create category"
        category = Category.new(:title => myTitle, :short_title => myTitle, :description => myTitle, 
          :old_uid => lc.uid, :old_type => 'typo3', :identifier => "de.kreawi.mobile.#{myTitle.parameterize('_')}".sub(/-/, "_"), :app_name => "iKreawi", :is_iap => false)
          category.save!
      end
    
      lc.legacy_questions.each do |legacy_question|
        puts "Question: #{legacy_question.title}"
        next if legacy_question.deleted == 1
        question = Question.find_by_old_uid_and_old_type(legacy_question.uid, 'typo3')
        if question
          question.answers.clear
          question.old_type = 'typo3'
          question.old_uid = legacy_question.uid
          body = legacy_question.question
          if(legacy_question.questiontype == 2)
            body << "\t\t<ol>"
            body << "\t\t\t<li>#{legacy_question.kombianswer_1}</li>" unless legacy_question.kombianswer_1.empty?
            body << "\t\t\t<li>#{legacy_question.kombianswer_2}</li>" unless legacy_question.kombianswer_2.empty?
            body << "\t\t\t<li>#{legacy_question.kombianswer_3}</li>" unless legacy_question.kombianswer_3.empty?
            body << "\t\t\t<li>#{legacy_question.kombianswer_4}</li>" unless legacy_question.kombianswer_4.empty?
            body << "\t\t\t<li>#{legacy_question.kombianswer_5}</li>" unless legacy_question.kombianswer_5.empty?
            body << "\t\t\t<li>#{legacy_question.kombianswer_6}</li>" unless legacy_question.kombianswer_6.empty?
            body << "\t\t\t<li>#{legacy_question.kombianswer_7}</li>" unless legacy_question.kombianswer_7.empty?
            body << "\t\t\t<li>#{legacy_question.kombianswer_8}</li>" unless legacy_question.kombianswer_8.empty?
            body << "\t\t\t<li>#{legacy_question.kombianswer_9}</li>" unless legacy_question.kombianswer_9.empty?
            body << "\t\t\t<li>#{legacy_question.kombianswer_10}</li>" unless legacy_question.kombianswer_10.empty?
            body << "\t\t</ol>"
          end
          question.body = body
          comment = legacy_question.commentedanswer
          #<link fileadmin/pdf-files_pro/herzinsuffizienz_klinik.pdf _blank download>siuhoisuh skdjhfgig asdf</link>
          question.comment = comment.gsub(/<link (.*?) (.*?) (.*?)>(.*?)<\/link>/, '<a href="http://www.kreawi-online.de/\1" target="\2" class="\3">\4</a>') 
          category.questions << question unless category.questions.exists?(question)
        else
          question = Question.new do |q|
            q.old_type = 'typo3'
            q.old_uid = legacy_question.uid
            body = legacy_question.question
            if(legacy_question.questiontype == 2)
              body << "\t\t<ol>"
              body << "\t\t\t<li>#{legacy_question.kombianswer_1}</li>" unless legacy_question.kombianswer_1.empty?
              body << "\t\t\t<li>#{legacy_question.kombianswer_2}</li>" unless legacy_question.kombianswer_2.empty?
              body << "\t\t\t<li>#{legacy_question.kombianswer_3}</li>" unless legacy_question.kombianswer_3.empty?
              body << "\t\t\t<li>#{legacy_question.kombianswer_4}</li>" unless legacy_question.kombianswer_4.empty?
              body << "\t\t\t<li>#{legacy_question.kombianswer_5}</li>" unless legacy_question.kombianswer_5.empty?
              body << "\t\t\t<li>#{legacy_question.kombianswer_6}</li>" unless legacy_question.kombianswer_6.empty?
              body << "\t\t\t<li>#{legacy_question.kombianswer_7}</li>" unless legacy_question.kombianswer_7.empty?
              body << "\t\t\t<li>#{legacy_question.kombianswer_8}</li>" unless legacy_question.kombianswer_8.empty?
              body << "\t\t\t<li>#{legacy_question.kombianswer_9}</li>" unless legacy_question.kombianswer_9.empty?
              body << "\t\t\t<li>#{legacy_question.kombianswer_10}</li>" unless legacy_question.kombianswer_10.empty?
              body << "\t\t</ol>"
            end
            q.body = body
            comment = legacy_question.commentedanswer
            #<link fileadmin/pdf-files_pro/herzinsuffizienz_klinik.pdf _blank download>siuhoisuh skdjhfgig asdf</link>
            q.comment = comment.gsub(/<link (.*?) (.*?) (.*?)>(.*?)<\/link>/, '<a href="http://www.kreawi-online.de/\1" target="\2" class="\3">\4</a>') 
          end
          category.questions << question  
        end
        question.save!
        unless(legacy_question.questiontype == 3)
          a1 = Answer.new(:body => legacy_question.answer_a, :correct => (legacy_question.correct_answers | 1 == legacy_question.correct_answers))
          question.answers << a1
          a1.save
          a2 = Answer.new(:body => legacy_question.answer_b, :correct => (legacy_question.correct_answers | 2 == legacy_question.correct_answers))
          question.answers << a2
          a2.save
          a3 = Answer.new(:body => legacy_question.answer_c, :correct => (legacy_question.correct_answers | 4 == legacy_question.correct_answers))
          question.answers << a3
          a3.save
          a4 = Answer.new(:body => legacy_question.answer_d, :correct => (legacy_question.correct_answers | 8 == legacy_question.correct_answers))
          question.answers << a4
          a4.save
          a5 = Answer.new(:body => legacy_question.answer_e, :correct => (legacy_question.correct_answers | 16 == legacy_question.correct_answers))
          question.answers << a5
          a5.save
        end
      end
      category.save!
    end
  end
end