class AddIsWorkingToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :is_working, :boolean
  end
end
