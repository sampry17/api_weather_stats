# frozen_string_literal: true

module Accuweather
  class BaseWeatherConditions
    def self.call
      new.call
    end

    def initialize
      @accuweather_client = Client.new
    end

    private

    attr_reader :accuweather_client

    def get_metric_temperature(attributes)
      attributes.dig('Temperature', 'Metric', 'Value')
    end

    def get_epoch_time(attributes)
      attributes['EpochTime']
    end
  end
end
