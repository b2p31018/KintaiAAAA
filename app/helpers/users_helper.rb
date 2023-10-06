module UsersHelper
  def format_basic_info(time)
    if time.present?
      format("%.2f", ((time.hour * 60) + time.min) / 60.0)
    else
      "N/A" # デフォルトの値を返す例
    end
  end
end