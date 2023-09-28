class AddDetailsToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :end_time, :datetime
    add_column :attendances, :task_description, :text
    add_column :attendances, :instructor_confirmation, :string
  end
end