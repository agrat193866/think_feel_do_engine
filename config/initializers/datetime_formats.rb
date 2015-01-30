Time::DATE_FORMATS.merge!(
  date_time_with_meridian: ->(t) { 
    if t.year != Date.today.year
      t.strftime("%b. %e %Y - %l:%M %P")
    else
      t.strftime("%b. %e - %l:%M %P")
    end
  },
  brief_date: ->(t) { 
    if t.year != Date.today.year
      t.strftime("%b %e %Y")
    else
      t.strftime("%b %e")
    end
  },
  time_with_meridian: '%l%P',
  brief_date_time: ->(t) {
    if t.year != Date.today.year
      t.strftime("%l%P on %b %e %Y")
    else
      t.strftime("%l%P on %b %e")
    end
  },
  compact: ->(t) {
    today = Date.today
    if t.to_date == today
      t.strftime("%l:%M %P")
    elsif t.year == today.year
      t.strftime("%b %e")
    else
      t.strftime("%b %e %Y")
    end
  }
)

Date::DATE_FORMATS.merge!(
  brief_date: ->(d) {
    if d.year != Date.today.year
      d.strftime("%b %e %Y")
    else
      d.strftime("%b %e")
    end
  }
)
