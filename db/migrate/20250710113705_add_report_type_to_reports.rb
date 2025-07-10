class AddReportTypeToReports < ActiveRecord::Migration[8.0]
  def change
    add_column :reports, :report_type, :string
  end
end
