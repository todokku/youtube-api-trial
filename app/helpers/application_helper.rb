module ApplicationHelper
  def render_notices
    render partial: 'partials/notices'
  end

  def print_link(body, url, alt = 'body is missing')
    if body.present?
      link_to body, url
    else
      link_to alt, url
    end
  end

  def print_datetime(datetime, format: :long)
    l(datetime, format: format) if datetime
  end

  def print_number(number)
    number&.to_s(:delimited)
  end

  def print_diff_numbers(num1, num2)
    return if num1.blank? || num2.blank?

    ret = print_number(num1 - num2)
    ret = '+' + ret if (num1 - num2).positive?
    ret
  end

  def print_diff_datetimes(datetime1, datetime2)
    return if datetime1.blank? || datetime2.blank?

    distance_of_time_in_words(datetime1, datetime2)
  end
end
