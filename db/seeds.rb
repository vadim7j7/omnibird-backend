# Create System Action Rules:
data = [
  {
    name: 'Weekend',
    group_key: :weekend,
    dates: [
      { name: 'Saturday', group_key: :weekend, week_day: 6 },
      { name: 'Sunday',   group_key: :weekend, week_day: 7 }
    ]
  },
  {
    name: 'US Holidays',
    group_key: :holidays,
    dates: [
      { name: 'New Year’s Day', group_key: :new_year,            month: 1,  day: 1 },                              # January 1
      { name: 'Martin Luther King Jr. Day', group_key: :mlk_day, month: 1,  week_day: 1, week_ordinal: 3 },        # Third Monday in January
      { name: "Presidents' Day", group_key: :presidents_day,     month: 2,  week_day: 1, week_ordinal: 3 },        # Third Monday in February
      { name: 'Memorial Day', group_key: :memorial_day,          month: 5,  week_day: 1, week_is_last_day: true }, # Last Monday in May
      { name: 'Juneteenth', group_key: :juneteenth,              month: 6,  day: 19 },                             # June 19
      { name: 'Independence Day', group_key: :independence_day,  month: 7,  day: 4 },                              # July 4
      { name: 'Labor Day', group_key: :labor_day,                month: 9,  week_day: 1, week_ordinal: 1 },        # First Monday in September
      { name: 'Columbus Day', group_key: :columbus_day,          month: 10, week_day: 1, week_ordinal: 2 },        # Second Monday in October
      { name: 'Veterans Day', group_key: :veterans_day,          month: 11, day: 11 },                             # November 11
      { name: 'Thanksgiving Day', group_key: :thanksgiving,      month: 11, week_day: 4, week_ordinal: 4 },        # Fourth Thursday in November
      { name: 'Christmas Day', group_key: :christmas,            month: 12, day: 25 }                              # December 25
    ]
  }
]

data.each do |item|
  record = ActionRule.find_or_create_by!(
    system_action: true,
    action_type: :skipping,
    group_key: item[:group_key],
    name: item[:name]
  )

  item[:dates].each { |date| record.action_rule_dates.find_or_create_by!(**date) }
end
