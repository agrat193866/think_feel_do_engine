Time::DATE_FORMATS.merge!(
  date_time_with_meridian: ->(time) { time.strftime("%B #{ time.day.ordinalize } @ %l%P") },
  time_with_meridian: '%l%P',
  brief_date_time: ->(t) {
    if t.year != Date.today.year
      t.strftime("%l%P on %b %e %Y")
    else
      t.strftime("%l%P on %b %e")
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
