class AddOriginalPruefungTypeIdToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :original_pruefung, :boolean
    add_column :categories, :type_id, :integer, :default => "-1"
  end
end
