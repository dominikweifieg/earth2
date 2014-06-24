class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.text :body
      t.text :comment
      t.references :category, index: true

      t.timestamps
    end
  end
end
