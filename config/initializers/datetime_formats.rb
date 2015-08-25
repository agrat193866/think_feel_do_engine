Date::DATE_FORMATS.merge!(
  participant_date: ->(d) {
    d.strftime("%b %d %Y")
  },
  user_date: ->(d) {
    d.strftime("%m/%d/%Y")
  }
)

Time::DATE_FORMATS.merge!(
  hour_with_meridian: ->(t) {
    t.strftime("%l %P")
  },
  participant_date: ->(t) {
    t.strftime("%b %d %Y")
  },
  standard: ->(t) { 
    t.strftime("%b %d %Y %I:%M %P")
  },
  user_date: ->(t) {
    t.strftime("%m/%d/%Y")
  },
  with_seconds: ->(t) {
    t.strftime("%b %d %Y %I:%M:%S %P")
  }
)
