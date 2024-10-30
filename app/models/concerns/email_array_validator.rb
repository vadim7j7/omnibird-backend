# frozen_string_literal: true

class EmailArrayValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    value.each do |email|
      next if email.match?(URI::MailTo::EMAIL_REGEXP)

      record.errors.add(attribute, "#{email} is not a valid email")
    end
  end
end
