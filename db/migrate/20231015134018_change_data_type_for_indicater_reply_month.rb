class ChangeDataTypeForIndicaterReplyMonth < ActiveRecord::Migration[5.1]
  def change
    reversible do |dir|
      change_column :attendances, :indicater_reply_month, 'integer USING CAST(indicater_reply_month AS integer)', default: 0
    end
  end
end
