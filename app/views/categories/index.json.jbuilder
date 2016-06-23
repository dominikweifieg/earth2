json.array!(@categories) do |category|
  json.extract! category, :id, :title, :short_title, :description, :identifier, :old_uid, :app_name, :area, :original_pruefung, :mc, :updated_at, :created_at
  json.url category_url(category, format: :json)
  json.question_count(category.questions.count)
end
