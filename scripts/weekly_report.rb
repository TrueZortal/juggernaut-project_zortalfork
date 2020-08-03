require_relative "../libs/interface/command_line"
require_relative "../libs/toggl/report"
require_relative "../libs/toggl/google_calendar_adapter"
require_relative "../libs/google/calendar"
require_relative "../date_time_helper"
require "date"

def build_weekly_summary(date)
  # TODO: I want this to compare total time with last week
  week_start = DateTimeHelper.get_week_start(date)
  week_end = DateTimeHelper.get_next_closest_sunday(date)
  toggl = Toggl::Report.new(week_start, week_end)
  adapter = Toggl::GoogleCalendarAdapter.new
  adapter.build_weekly_summary(report: toggl.report_summary, report_day: week_end + 1)
end

def cl_date
  cli = Interface::CommandLine.new(args: ARGV)
  cli.get_runtime_date(default: Date.today - 7)
end

puts "\n⌨️  Running weekly_report script"
prepared_entry_list = build_weekly_summary(cl_date)

puts "\ninitiating Google Calendar integration"
calendar = Google::Calendar.new
calendar.add_list_of_entries_no_duplicates(prepared_entry_list)
