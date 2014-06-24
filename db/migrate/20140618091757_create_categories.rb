class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :title
      t.string :short_title
      t.text :description
      t.string :identifier
      t.integer :old_uid
      t.string :old_type
      t.string :app_name
      t.string :area
      
      t.timestamps
    end
  end
end
