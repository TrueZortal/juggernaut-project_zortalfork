# frozen_string_literal: true

require_relative 'trends'

module Juggernaut
  module Storage
    def self.trends_destination
      Storage::Trends.new.destination
    end
  end
end
