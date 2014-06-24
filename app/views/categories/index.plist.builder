xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
xml.declare! :DOCTYPE, :plist, :PUBLIC, "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"
xml.plist("version" => "1.0") {
  xml.dict {
    xml.key("token")
    xml.string(@token)
    xml.key("categories")
    xml.array {
      @categories.each do |category|
        xml.string(category.identifier)
      end
    }
  }
}