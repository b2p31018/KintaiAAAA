class ChangeDataTypeForIndicaterReplyMonth < ActiveRecord::Migration[5.1]
  def change
    change_column :attendances, :indicater_reply_month, :integer, default: 0
  end
end
