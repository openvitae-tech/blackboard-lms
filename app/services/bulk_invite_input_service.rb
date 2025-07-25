# frozen_string_literal: true

require 'csv'

class BulkInviteInputService
  include Singleton

  def process(file_input)
    return [] unless file_input.respond_to? :read
    return [] unless ['text/csv', 'text/plain'].include?(file_input.content_type)

    parse_csv(file_input.read)
  rescue IOError => _e
    []
  end

  private

  def parse_csv(contents)
    csv = CSV.parse(contents, headers: true)
    valid_records = []
    # skip invalid records
    csv.each do |row|
      next if row.length < 2
      next if row[0].blank? || row[0].strip.length < 2
      next if row[1].blank? || !User::PHONE_REGEXP.match?(row[1].strip)

      valid_records.push([row[0].strip, row[1].strip.downcase])
    end

    valid_records
  end
end
