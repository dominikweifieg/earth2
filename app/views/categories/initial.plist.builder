xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
xml.declare! :DOCTYPE, :plist, :PUBLIC, "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"
xml.plist("version" => "1.0") {
  xml.dict {
    xml.key("ProductId")
    xml.string(@category.identifier)
    xml.key("CreationDate")
    xml.date(@category.created_at.strftime("%Y-%m-%dT%H:%M:%SZ"))
    xml.key("UpdateDate")
    xml.date(@category.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ"))
    xml.key("Original_Pruefung")
    xml.true if @category.original_pruefung
    xml.false unless @category.original_pruefung
    xml.key("Category") 
    xml.dict {
      xml.key("Name")
      xml.string(@category.title)
      xml.key("ShortName")
      xml.string(@category.short_title)
      xml.key("Type_Id")
      xml.integer(@category.type_id.to_s)
      xml.key("Questions")
      xml.array {
        @category.questions.each do |question|
          xml.dict {
            xml.key("Text")
            xml.string {
              xml.cdata!(question.body)
            }
            xml.key("Comment")
            xml.string {
              xml.cdata!(question.comment)
            }
            xml.key("Answers")
            xml.array {
              question.answers.each do |answer|
                xml.dict {
                  xml.key("Text")
                  xml.string(answer.body)
                  xml.key("Correct")
                  xml.true if answer.correct
                  xml.false unless answer.correct
                }
              end
            }
          }
        end
      }
    }
  }
}