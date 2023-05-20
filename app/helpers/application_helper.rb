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
end
