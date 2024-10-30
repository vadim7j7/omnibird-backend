# frozen_string_literal: true

class WithinTimeValidator < ActiveModel::Validator
  def validate(record)
    all_fields = options[:fields].values.flatten
    return if all_fields.any?(&:blank?)
    return if all_fields.map { |item| record.respond_to?(item) }.any?(false)

    outer_from_field = options.dig(:fields, :outer_fields, 0)
    outer_to_field = options.dig(:fields, :outer_fields, 1)
    inner_from_field = options.dig(:fields, :inner_fields, 0)
    inner_to_field = options.dig(:fields, :inner_fields, 1)
    return if [ outer_from_field, outer_to_field, inner_from_field, inner_to_field ].any?(&:blank?)

    outer_from = record.send(outer_from_field)
    outer_to   = record.send(outer_to_field)
    inner_from = record.send(inner_from_field)
    inner_to   = record.send(inner_to_field)
    return if [ outer_from, outer_to, inner_from, inner_to ].any?(&:blank?)

    record.errors.add(inner_from_field, "must be after #{outer_from_field}") if inner_from < outer_from
    record.errors.add(inner_to_field, "must be before #{outer_to_field}") if inner_to > outer_to
  end
end
