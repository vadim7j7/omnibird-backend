# Create System Action Rules:
data = [
  {
    name: 'Weekend',
    group_key: :weekend,
    dates: [
      { name: 'Saturday', group_key: :weekend, day_of_week: 6 },
      { name: 'Sunday', group_key: :weekend, day_of_week: 7 }
    ]
  },
  {
    name: 'US Holidays',
    group_key: :holidays,
    dates: [
      { name: 'New Year’s Day', group_key: :new_year, day: 1, month: 1 },
      { name: 'Christmas', group_key: :xmas, day: 25, month: 12 },
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
