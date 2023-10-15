class ChangeDataTypeForIndicaterReplyEdit < ActiveRecord::Migration[5.1]
  def change
    change_column :attendances, :indicater_reply_edit, :integer, default: 0
  end
end
