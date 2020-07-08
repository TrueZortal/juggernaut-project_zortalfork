module Toggl
  require_relative "../requests"
  require "base64"
  require "json"

  class Report
    # TODO: Add unit tests.

    def initialize(start_date, end_date = "")
      puts "inside Toggl.Report.initialize"
      @config = get_json_from_file("libs/toggl/config.secret.json")
      @api_token = api_token
      @start_date = start_date
      @end_date = end_date.to_s.empty? ? start_date : end_date
      @request_adapter = Requests::Adapter.new
      auth_object = authenticate_user
      @user_agent = auth_object[:email]
      @workspace_id = auth_object[:workspace_id]
    end

    attr_reader :start_date

    def authenticate_user
      response = @request_adapter.get_request(auth_address, auth_headers)
      body = JSON.parse(response[:body])
      email = body["data"]["email"]

      # TODO: what if the user has more workspaces?
      workspace = body["data"]["workspaces"].first
      {email: email, workspace_id: workspace["id"]}
    end

    def report_summary
      report("summary")
    end

    def report_details
      report("details")
    end

    def get_work_start_time(the_day_in_question)
      report = report_details
      time_entry = get_first_time_entry_of_the_day(report)
      # parse_time(time_entry['start'])
      time_entry["start"]
    end

    def get_total_work_time(the_day_in_question)
      2 * 3600
    end

    def get_total_time
      @total_time
    end

    def get_time_for(date:, category:, report_detailed:, report_summarized:)
      # TODO: define outside rules for these categories
      # TODO: Add tests before switching to these rules
      if category == "consumption"
        category_entry_list = report_detailed["data"].select do |time_entry|
          time_entry["tags"].include?("game") ||
          time_entry["project"] == "Abnegation - Passive entertainment" ||
          time_entry["project"] == "Growth - Reading" ||
          time_entry["project"] == "Growth - Study" ||
          time_entry["project"] == "Growth - Edutainment" ||
          time_entry["project"] == "Growth - intentional Video"
        end
        if category_entry_list.empty?
          return 0
        else
          total_category_time = category_entry_list.map { |entry| entry["dur"] }.sum
          return total_category_time
        end
      end
      if category == "creative"
        category_entry_list = report_detailed["data"].select do |time_entry|
          time_entry["description"] == "Focused work" ||
          time_entry["project"] == "Creative - Writing" ||
          time_entry["project"] == "Dev - Scripts and utilities" ||
          time_entry["project"] == "Dev - Finance app" ||
          time_entry["project"] == "Dev - Resume generator" ||
          time_entry["project"] == "Dev - Other Projects"
        end
        if category_entry_list.empty?
          return 0
        else
          total_category_time = category_entry_list.map { |entry| entry["dur"] }.sum
          return total_category_time
        end
      end
      if category == "work"
        category_entry_list = report_detailed["data"].select do |time_entry|
          time_entry["tags"].include?("work")
        end
        if category_entry_list.empty?
          return 0
        else
          total_category_time = category_entry_list.map { |entry| entry["dur"] }.sum
          return total_category_time
        end
      end
      if category == "games"
        category_entry_list = report_detailed["data"].select do |time_entry|
          time_entry["tags"].include?("game")
        end
        if category_entry_list.empty?
          return 0
        else
          total_category_time = category_entry_list.map { |entry| entry["dur"] }.sum
          return total_category_time
        end
      end
      if category == "exercise"
        category_entry_list = report_detailed["data"].select do |time_entry|
          time_entry["tags"].include?("exercise")
        end
        if category_entry_list.empty?
          return 0
        else
          total_category_time = category_entry_list.map { |entry| entry["dur"] }.sum
          return total_category_time
        end
      end
      if category == "reading"
        category_entry_list = report_summarized["data"].select do |time_entry|
          time_entry["title"]["project"] == "Growth - Reading"
        end
        if category_entry_list.empty?
          return 0
        else
          return category_entry_list.first["time"]
        end
      end
      if category == "writing"
        category_entry_list = report_summarized["data"].select do |time_entry|
          time_entry["title"]["project"] == "Creative - Writing"
        end
        if category_entry_list.empty?
          return 0
        else
          return category_entry_list.first["time"]
        end
      end
      if category == "sleep"
        category_entry_list = report_summarized["data"].select do |time_entry|
          time_entry["title"]["project"] == "Sleeping"
        end
        if category_entry_list.empty?
          return 0
        else
          return category_entry_list.first["time"]
        end
      end
    end

    private

    attr_reader :workspace_id

    def get_json_from_file(file_path)
      file = File.read(file_path)
      JSON.parse(file)
    end

    def api_token
      @config["tokens"]["api"]
    end

    def basic_auth_token
      # TODO: replace with calculated_token when that's working
      # puts "external_token: \n#{external_token}"
      # puts "base64_calculated_basic_auth_token: \n#{base64_calculated_basic_auth_token}"
      # puts "request_adapter_basic_auth: \n#{request_adapter_basic_auth}"
      # external_token
      base64_calculated_basic_auth_token
    end

    def report(detail_level)
      report_path = report_path(detail_level)
      response = @request_adapter.get_request(report_path, auth_headers)
      body = JSON.parse(response[:body])
      @total_time = body["total_grand"]
      body
    end

    def external_token
      "Basic " + @config["tokens"]["base64"]
    end

    def base64_calculated_basic_auth_token
      "Basic " + Base64.encode64(username + ":" + password).strip
    end

    def request_adapter_basic_auth
      @request_adapter.basic_auth_token(auth_address, username, password)
    end

    def username
      api_token
    end

    def password
      "api_token"
    end

    def auth_address
      "https://www.toggl.com/api/v8/me"
    end

    def report_path(detail_level)
      "#{reports_api_base_url}/#{detail_level}?#{reports_api_params}"
    end

    def reports_api_base_url
      "https://toggl.com/reports/api/v2"
    end

    def reports_api_params
      "#{identifying_params}&#{date_params}&#{grouping_params}&rounding=on"
    end

    def identifying_params
      "user_agent=#{@user_agent}&workspace_id=#{@workspace_id}"
    end

    def date_params
      "since=#{@start_date}&until=#{@end_date}"
    end

    def grouping_params
      "grouping=projects&subgrouping=time_entries"
    end

    def auth_headers
      [{key: "Authorization", value: basic_auth_token}]
    end

    def get_first_time_entry_of_the_day(report)
      # TODO: this needs to choose the correct entry instead. Could use a project or client argument
      report["data"].first
    end

    def parse_time(toggl_time)
      date_time = toggl_time.split("T")
      date_string = date_time.first
      time_and_zone = date_time.last.split("+")
      time_string = time_and_zone.first
      time_zone_string = "+" + time_and_zone.last
      date_elements = date_string.split("-")
      year = date_elements[0].to_i
      month = date_elements[1].to_i
      day = date_elements[2].to_i
      time_elements = time_string.split(":")
      hour = time_elements[0].to_i
      minute = time_elements[1].to_i
      second = time_elements[2].to_i
      Time.new(year, month, day, hour, minute, second, time_zone_string)
    end
  end
end
