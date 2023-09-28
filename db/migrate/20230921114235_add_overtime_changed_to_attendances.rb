class AddOvertimeChangedToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overtime_changed, :boolean, default: false
  end
end
