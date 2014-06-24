xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
xml.category {
  xml.name {
    xml.cdata!(@category.title)
  }
  xml.short_name {
    xml.cdata!(@category.short_title)
  }

  xml.original_question(@category.original_pruefung)
  xml.identifier(@category.identifier)
  xml.type_id(@category.type_id)
  xml.questions {
     @category.questions.each do |question|
       xml.question {
         xml.body {
          xml.cdata!(question.body)
         }
         xml.comment{
           xml.cdata!(question.comment)
         }
         xml.answers {
           question.answers.each do |answer|
             xml.answer("correct" => answer.correct) {
               xml.body {
                 xml.cdata!(answer.body)
               }
             }
           end
         }
       }
     end
  }
}