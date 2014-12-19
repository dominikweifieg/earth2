class MakeCategoryQuestionsMN < ActiveRecord::Migration
  def change
    quest_cat_array = Array.new(10000) {|index| -1 }
    reversible do |dir|
      dir.up {
        questions = Question.all
        questions.each do |q| 
          quest_cat_array[q.id] = q.category_id
        end
      }
    end
    add_column :categories, :is_iap, :boolean, :default => false
    create_table :category_questions do |t|
      t.references :category, index: true
      t.references :question, index: true
    end
    
    reversible do |dir|
      dir.up {
        quest_cat_array.each_index do |q_id|
          c_id = quest_cat_array[q_id]
          unless c_id == -1
            cat = Category.find_by(id: c_id)
            if cat
              quest = Question.find(q_id)
              cat.questions << quest
            end
          end
        end
      }
      dir.down {
        
      }
    end
    
  end
end
