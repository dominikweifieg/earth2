class AddMcToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :mc, :boolean
  end
end
