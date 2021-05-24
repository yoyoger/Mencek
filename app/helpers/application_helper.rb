module ApplicationHelper

  def base_title
    "らーめんの里"
  end

  def full_title(page_title='')
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end

  def greeting
    hour = Time.current.hour
    if (5 <= hour) && (hour <=10)
      "おはようございます"
    elsif (11 <= hour) && (hour <= 17)
      "こんにちは"
    else
      "こんばんは"
    end
  end
end
