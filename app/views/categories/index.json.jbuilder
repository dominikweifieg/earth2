json.array!(@categories) do |category|
  json.extract! category, :id, :title, :short_title, :description, :identifier, :old_uid, :app_name, :area, :original_pruefung, :mc
  json.url category_url(category, format: :json)
end
