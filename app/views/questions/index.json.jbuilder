json.array!(@questions) do |question|
  json.extract! question, :id, :body, :comment, :category_id
  json.url question_url(question, format: :json)
end
