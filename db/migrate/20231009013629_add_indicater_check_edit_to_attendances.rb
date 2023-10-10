class AddIndicaterCheckEditToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :indicater_check_edit, :string
  end
end
