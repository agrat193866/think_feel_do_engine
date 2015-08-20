Time::DATE_FORMATS.merge!(
  date: ->(t) {
    t.strftime("%m/%d/%Y")
  },
  hour_with_meridian: ->(t) {
    t.strftime("%l %P")
  },
  standard: ->(t) { 
    t.strftime("%b %d %Y %I:%M %P")
  }
)

Date::DATE_FORMATS.merge!(
  date: ->(d) {
    d.strftime("%m/%d/%Y")    
  }
)
