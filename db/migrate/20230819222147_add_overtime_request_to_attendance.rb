class AddOvertimeRequestToAttendance < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overtime_request_to, :string
  end
end
