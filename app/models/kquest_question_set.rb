class KquestQuestionSet < ActiveRecord::Base
  establish_connection :kquest
  
  self.table_name = "fragenset"
  self.primary_key = "set_id"
  self.inheritance_column = ""
  
  default_scope order('set_name ASC')
  
  has_many :kquest_links, :foreign_key => :setID
  has_many :kquest_questions, :through => :kquest_links
  
  def self.import_all
    categories = KquestQuestionSet.all
    categories.each do |lc| 
      old_time_stamp = 0
      needs_iap_updates = false
      category = Category.find_by_old_uid_and_old_type(lc.set_id, 'set')
      if(category)
        # category.questions.clear
        old_time_stamp = category.updated_at.to_i
        category.old_type = 'set'
        category.touch
        puts "Found #{lc.set_name}"
      else
        puts "Create new category for #{lc.set_name}"
        category = Category.new(:title => lc.set_name, :short_title => lc.set_name, :description => "", 
          :old_uid => lc.set_id, :old_type => 'set', :identifier => "de.kreawi.mobile.#{lc.set_name.parameterize('_')}".sub(/-/, "_"), :app_name => "", :is_iap => false)
      end
    
      lc.kquest_questions.each do |legacy_question|
        next if legacy_question.deleted == 1
        question = Question.find_by_old_uid_and_old_type(legacy_question.uid, 'set')
        if question
          question.answers.clear
          question.old_type = 'cat'
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
          if legacy_question.tstamp > old_time_stamp 
            needs_iap_updates = true
          end
        else
          question = Question.new do |q|
            q.old_type = 'cat'
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
          needs_iap_updates = true
        end
        question.save
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
      category.save
      if needs_iap_updates 
        category.in_app_categories.each {|c| c.touch }
      end
    end
  end
end
