# frozen_string_literal: true

module RecordOrdering
  def self.records_in_order(records, order)
    # sorts a list of records as per the order defined in order array
    # record in records must respond to :id
    h = {}
    order.each { |o| h[o] = nil }
    records.each { |rec| h[rec.id] = rec }
    h.values
  end
end
