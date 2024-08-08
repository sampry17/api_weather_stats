# frozen_string_literal: true

module Api
  module V1
    module Weather
      class WeatherController < ApplicationController
        before_action :day_conditions, only: %i[historical max min avg by_time]
        before_action :current_conditions, only: [:current]

        # Historical data endpoints
        def historical
          render json: @day_conditions.as_json
        end

        def max
          render json: max_temperature
        end

        def min
          render json: min_temperature
        end

        def avg
          render json: avg_temperature
        end

        # Current weather endpoint

        def current
          render json: current_conditions.as_json
        end

        # By time endpoint
        def by_time
          timestamp = params[:timestamp]
          if timestamp.present?
            result = weather_by_time(timestamp)

            if result[:error]
              render json: { error: result[:error] }, status: result[:status]
            else
              render json: result[:data]
            end
          else
            render json: { error: 'Timestamp parameter is required' }, status: :bad_request
          end
        end

        private

        def day_conditions
          @day_conditions ||= Accuweather::DayWeatherConditions.call
        end

        def max_temperature
          @day_conditions.max_by { |data| data[:temperature] }
        end

        def min_temperature
          @day_conditions.min_by { |data| data[:temperature] }
        end

        def avg_temperature
          total_temperature = @day_conditions.sum { |data| data[:temperature] }
          avg_value = total_temperature.to_f / @day_conditions.size

          { avg_temperature: avg_value.round(1) }
        end

        def current_conditions
          @current_conditions ||= Accuweather::CurrentWeatherConditions.call
        end

        def weather_by_time(timestamp)
          timestamp = timestamp.to_i
          time_now = Time.now.to_i
          correct_time_range = (time_now - 3600 * 24)..time_now

          if correct_time_range.cover?(timestamp)
            closest_entry = @day_conditions.min_by { |entry| (entry[:timestamp] - timestamp).abs }
            { data: closest_entry }
          else
            { error: 'The timestamp is outside the 24 hour range', status: :not_found }
          end
        end
      end
    end
  end
end
