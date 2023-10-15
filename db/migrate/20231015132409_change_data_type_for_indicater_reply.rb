class ChangeDataTypeForIndicaterReply < ActiveRecord::Migration[5.1]
  def change
    change_column :attendances, :indicater_reply, :integer, default: 0
  end
end
