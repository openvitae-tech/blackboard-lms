# frozen_string_literal: true

require 'csv'

class BulkInviteInputService
  include Singleton

  def process(file_input, country_iso)
    return [] unless file_input.respond_to? :read
    return [] unless ['text/csv', 'text/plain'].include?(file_input.content_type)

    parse_csv(file_input.read, country_iso)
  rescue IOError => _e
    []
  end

  private

  def parse_csv(contents, country_iso)
    csv = CSV.parse(contents, headers: true)
    valid_records = []
    # skip invalid records
    csv.each do |row|
      next if row.length < 2
      next if row[0].blank? || row[0].strip.length < 2
      next if row[1].blank? || !valid_phone?(row[1].strip, country_iso)

      valid_records.push([row[0].strip, row[1].strip.downcase])
    end

    valid_records
  end

  def valid_phone?(phone, country)
    Phonelib.valid_for_country? phone, country
  end
end
