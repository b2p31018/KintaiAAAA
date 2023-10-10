class AddChangeMonthToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :change_month, :boolean, default: false
  end
end
