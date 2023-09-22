# require_relative '../lib/google/calendar'
# $LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))

require 'juggernaut'
# require 'rspec'

required_gems = [
  'google-apis-calendar_v3',
  'google-apis-sheets_v4',
  'googleauth',
  'googleauth/stores/file_token_store',
  'date',
  'fileutils',
  'json',
  'rspec',
  'juggernaut'
]

  loaded_gems = required_gems.select do |gem_name|
    $LOADED_FEATURES.any? { |feature| feature.include?(gem_name) }
  end

  puts 'Loaded gems:'
  puts loaded_gems
  # puts $LOADED_FEATURES

  # test_sheet = Juggernaut::Google::Sheets.new(file_id: 'test')
  # date = Date.today.next_month.strftime("%B %Y")
  # test_sheet.add_sheet_to_spreadsheet(date)

# require 'google-apis-calendar_v3'
# @service = Juggernaut::Google::Apis::CalendarV3::CalendarService.new
# p @service

calendar_object = Juggernaut::Google::Calendar.new(calendar_name: 'test')
fetched = calendar_object.fetch_events(Date.today)
p fetched
