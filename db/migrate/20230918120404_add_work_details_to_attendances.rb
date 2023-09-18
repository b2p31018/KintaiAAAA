class AddWorkDetailsToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :work_details, :string
  end
end
