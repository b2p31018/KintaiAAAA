class ChangeDataTypeForIndicaterReply < ActiveRecord::Migration[5.1]
  def change
    reversible do |dir|
      change_column :attendances, :indicater_reply, 'integer USING CAST(indicater_reply AS integer)', default: 0
    end
  end
end
