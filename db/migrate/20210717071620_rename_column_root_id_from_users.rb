class RenameColumnRootIdFromUsers < ActiveRecord::Migration[6.1]
  def change
    rename_column :users, :root_id, :rut
  end
end
