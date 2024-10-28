# Create System Action Rules:
data = [
  { name: 'Weekend', dates: [{ day_of_week: 6 }, { day_of_week: 7 }] }
]

data.each do |item|
  record = ActionRule.find_or_create_by!(system_action: true, action_type: :skipping, name: item[:name])
  item[:dates].each { |date| record.action_rule_dates.find_or_create_by!(**date) }
end
