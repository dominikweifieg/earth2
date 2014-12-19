class AddOldUidAndTypeToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :old_uid, :integer
    add_column :questions, :old_type, :string
  end
end
