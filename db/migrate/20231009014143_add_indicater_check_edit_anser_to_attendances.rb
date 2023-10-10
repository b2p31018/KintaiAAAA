class AddIndicaterCheckEditAnserToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :indicater_check_edit_anser, :string
  end
end
