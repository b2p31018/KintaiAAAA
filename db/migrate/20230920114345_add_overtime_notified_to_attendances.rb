class AddOvertimeNotifiedToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overtime_notified, :boolean, default: false
  end
end