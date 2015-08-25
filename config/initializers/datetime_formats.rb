Date::DATE_FORMATS.merge!(
  date: ->(d) {
    d.strftime("%m/%d/%Y")
  },
  participant_date: ->(d) {
    d.strftime("%b %d %Y")
  }
)

Time::DATE_FORMATS.merge!(
  date: ->(t) {
    t.strftime("%m/%d/%Y")
  },
  hour_with_meridian: ->(t) {
    t.strftime("%l %P")
  },
  participant_date: ->(t) {
    t.strftime("%b %d %Y")
  },
  standard: ->(t) { 
    t.strftime("%b %d %Y %I:%M %P")
  },
  with_seconds: ->(t) {
    t.strftime("%b %d %Y %I:%M:%S %P")
  }
)
