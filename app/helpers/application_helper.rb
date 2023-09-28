module ApplicationHelper
  def full_title(page_name = "")
    base_title = "AttendanceApp"
    if page_name.empty?
      base_title
    else
      page_name + " | " + base_title
    end
  end

  def weekday_classes(weekday)
    case weekday
    when 0 # Sunday
      'sunday'
    when 6 # Saturday
      'saturday'
    else
      ''
    end
  end
  
  def notification_items(overtime_changed_count)
    [
      { name: "所属長承認申請", count: nil },
      { name: "勤怠変更申請", count: nil },
      { name: "残業申請", count: overtime_changed_count }
    ]
  end

end
