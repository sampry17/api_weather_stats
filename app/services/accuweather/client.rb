# frozen_string_literal: true

module Accuweather
  class Client
    ROOT = 'http://dataservice.accuweather.com/'

    attr_reader :api_key, :location_key

    def initialize(api_key = ENV.fetch('ACCUWEATHER_API_KEY'), location_key = ENV.fetch('LOCATION_KEY'))
      @api_key = api_key
      @location_key = location_key

      @conn = Faraday.new do |builder|
        builder.response :json, content_type: /\bjson$/
        builder.adapter Faraday.default_adapter
      end
    end

    def current_conditions
      Rails.cache.fetch('request_current_conditions', expires: 1.hour) do
        resp = @conn.get ROOT + "currentconditions/v1/#{location_key}" do |req|
          req.params.merge!(apikey: api_key)
        end

        raise 'Error getting current weather conditions' if link_error? resp

        resp.body
      end
    end

    def historical_conditions
      Rails.cache.fetch('request_historical_conditions', expires: 1.hour) do
        resp = @conn.get ROOT + "currentconditions/v1/#{location_key}/historical/24" do |req|
          req.params.merge!(apikey: api_key)
        end

        raise 'Error getting historical weather conditions' if link_error? resp

        resp.body
      end
    end

    private

    def link_error?(resp, wait_status: 200)
      resp.status != wait_status
    end
  end
end
