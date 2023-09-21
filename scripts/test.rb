# require_relative '../lib/google/calendar'

require 'juggernaut'
# @service = Google::Apis::CalendarV3::CalendarService.new
# p @service

calendar_object = Juggernaut::GoogleCalendar::Calendar.new(calendar_name: 'test')
fetched = calendar_object.fetch_events(Date.today)
p fetched
