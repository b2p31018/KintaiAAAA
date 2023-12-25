class ChangeDataTypeForIndicaterReplyEdit < ActiveRecord::Migration[5.1]
  def change
    change_column :attendances, :indicater_reply_edit, 'integer USING indicater_reply_edit::integer'
  end
end
