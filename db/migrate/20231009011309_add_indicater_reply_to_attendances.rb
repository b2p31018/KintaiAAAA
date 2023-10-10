class AddIndicaterReplyToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :indicater_reply, :string
  end
end
