class KquestCategoriesController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @categories = KquestCategory.all
  end

  def show
    @category = KquestCategory.find_by_cid(params[:id])
    @imported = Category.exists?(['old_uid = ? AND old_type = "cat"', params[:id]])
    @earth_category = Category.find_by_old_uid_and_old_type(params[:id], 'cat')
    
    if(params[:import].present?)
      import(@category, @imported)
      redirect_to categories_path
    end
  end

  private 
  def import(legacy_category, reimport)
    if(reimport)
      category = Category.find_by_old_uid_and_old_type(@category.cid, 'cat')
      # category.questions.clear
      category.touch
      
      category.in_app_categories.each {|c| c.touch }
    else
      category = Category.new(:title => legacy_category.cat_title, :short_title => legacy_category.cat_title, :description => "", 
        :old_uid => legacy_category.cid, :old_type => 'cat', :identifier => "de.kreawi.mobile.#{legacy_category.cat_title.parameterize('_')}".sub(/-/, "_"), :app_name => "", :is_iap => false)
    end
    
    legacy_category.kquest_questions.each do |legacy_question|
      next if legacy_question.deleted == 1
      question = Question.find_by_old_uid(legacy_question.uid)
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
  end

end
