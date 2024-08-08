# frozen_string_literal: true

module Accuweather
  class CurrentWeatherConditions < BaseWeatherConditions
    def call
      condition_attribute = accuweather_client.current_conditions.first
      Rails.logger.debug("Condition Attribute: #{condition_attribute.inspect}")
      get_current_weather_conditions(condition_attribute)
    end

    private

    attr_reader :accuweather_client

    def get_current_weather_conditions(attribute)
      Rails.cache.fetch('current_conditions', expires: 1.hour) do
        {
          temperature: get_metric_temperature(attribute),
          timestamp: get_epoch_time(attribute)
        }
      end
    end
  end
end
