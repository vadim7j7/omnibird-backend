# frozen_string_literal: true

class TimeWindowValidator < ActiveModel::Validator
  def validate(record)
    options[:fields].each do |from_field, to_field|
      from_time = record.send(from_field)
      to_time   = record.send(to_field)
      next if from_time.blank? && to_time.blank?

      if from_time.present? && to_time.present?
        record.errors.add(to_field, "must be after #{from_field.to_s.humanize.downcase}") if from_time >= to_time
      else
        record.errors.add(from_field, 'cannot be blank') if from_time.blank?
        record.errors.add(to_field, 'cannot be blank') if to_time.blank?
      end
    end
  end
end
