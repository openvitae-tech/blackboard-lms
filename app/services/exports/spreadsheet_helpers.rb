# frozen_string_literal: true

module Exports
  module SpreadsheetHelpers
    tokens = JSON.parse(Rails.root.join('config/export_colors.json').read)

    # caxlsx expects hex strings without the leading '#'
    HEADER_COLOR     = tokens['export-header'].delete('#').freeze
    HEADER_FG        = tokens['export-header-fg'].delete('#').freeze
    WIDEST_GAP_COLOR = tokens['export-highlight'].delete('#').freeze

    def duration_label(range)
      "#{range.begin.strftime('%d %b %Y')} – #{range.end.strftime('%d %b %Y')}"
    end

    def delta_label(value)
      return 'No change' if value.to_i.zero?

      value.to_i.positive? ? "+#{value}" : value.to_s
    end

    def format_seconds(seconds)
      return '0m' if seconds.to_i.zero?

      hours   = seconds / 3600
      minutes = (seconds % 3600) / 60
      hours.positive? ? "#{hours}h #{minutes}m" : "#{minutes}m"
    end
  end
end
