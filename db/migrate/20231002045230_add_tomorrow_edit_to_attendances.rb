class AddTomorrowEditToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :tomorrow_edit, :datetime
  end
end
