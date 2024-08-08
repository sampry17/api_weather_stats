# frozen_string_literal: true

module Accuweather
  class DayWeatherConditions < BaseWeatherConditions
    def call
      conditions_attributes_list = accuweather_client.historical_conditions
      get_day_weather_conditions(conditions_attributes_list)
    end

    private

    attr_reader :accuweather_client

    def get_day_weather_conditions(attribute_list)
      Rails.cache.fetch('day_conditions', expires: 1.hour) do
        attribute_list.map do |attributes|
          {
            temperature: get_metric_temperature(attributes),
            timestamp: get_epoch_time(attributes)
          }
        end
      end
    end
  end
end
