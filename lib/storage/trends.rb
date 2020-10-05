# frozen_string_literal: true

module Storage
  class Trends
    attr_reader :destination

    def initialize
      @destination = spreadsheet_adapter.connect(file_id: 'trends', default_range: 'Data!A:I')
    end

    def self.destination
      # new.destination
      spreadsheet_adapter.connect(file_id: 'trends', default_range: 'Data!A:I')
    end

    private

    def spreadsheet_adapter
      Integrations::Google::Sheets
    end

    private_class_method :spreadsheet
  end
end
