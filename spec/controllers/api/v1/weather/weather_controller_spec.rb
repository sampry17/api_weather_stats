# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Weather::WeatherController do
  describe 'historical endpoints' do
    let(:day_conditions_data) do
      [
        { temperature: 1.0, timestamp: 1 },
        { temperature: 2.0, timestamp: 2 },
        { temperature: 3.0, timestamp: 3 }
      ]
    end

    before { allow(Accuweather::DayWeatherConditions).to receive(:call).and_return(day_conditions_data) }

    describe 'GET api/v1/weather/historical' do
      let(:request) { get :historical }

      let(:expected_response_result) do
        [
          { 'temperature' => 1.0, 'timestamp' => 1 },
          { 'temperature' => 2.0, 'timestamp' => 2 },
          { 'temperature' => 3.0, 'timestamp' => 3 }
        ]
      end

      it 'returns response with historical day conditions' do
        request

        expect(JSON.parse(response.body)).to eq(expected_response_result)
      end
    end

    describe 'GET api/v1/weather/historical/max' do
      let(:request) { get :max }

      let(:expected_response_result) { { 'temperature' => 3.0, 'timestamp' => 3 } }

      it 'returns response with max day conditions' do
        request

        expect(JSON.parse(response.body)).to eq(expected_response_result)
      end
    end

    describe 'GET api/v1/weather/historical/min' do
      let(:request) { get :min }

      let(:expected_response_result) { { 'temperature' => 1.0, 'timestamp' => 1 } }

      it 'returns response with min day conditions' do
        request

        expect(JSON.parse(response.body)).to eq(expected_response_result)
      end
    end

    describe 'GET api/v1/weather/historical/avg' do
      let(:request) { get :avg }

      let(:expected_response_result) { { 'avg_temperature' => 2.0 } }

      it 'returns response with avg day conditions' do
        request

        expect(JSON.parse(response.body)).to eq(expected_response_result)
      end
    end
  end

  describe 'current endpoint' do
    let(:day_conditions_data) { { temperature: 1.0, timestamp: 1 } }

    before { allow(Accuweather::CurrentWeatherConditions).to receive(:call).and_return(day_conditions_data) }

    describe 'GET api/v1/weather/current' do
      let(:request) { get :current }

      let(:expected_response_result) { { 'temperature' => 1.0, 'timestamp' => 1 } }

      it 'returns response with current conditions' do
        request

        expect(JSON.parse(response.body)).to eq(expected_response_result)
      end
    end
  end

  describe 'by_time endpoint' do
    let(:day_conditions) do
      [
        { timestamp: (Time.now - 2.hours).to_i, temperature: 20 },
        { timestamp: (Time.now - 1.hour).to_i, temperature: 22 },
        { timestamp: Time.now.to_i, temperature: 25 }
      ]
    end

    before do
      allow(Accuweather::DayWeatherConditions).to receive(:call).and_return(day_conditions)
    end

    describe 'GET api/v1/weather/by_time' do
      context 'when timestamp is provided and within the 24 hour range' do
        it 'returns the weather data closest to the timestamp' do
          timestamp = (Time.now - 1.hour).to_i
          get :by_time, params: { timestamp: timestamp }

          expect(response).to have_http_status(:success)
          json_response = JSON.parse(response.body)
          expect(json_response['temperature']).to eq(22)
        end
      end

      context 'when timestamp is not provided' do
        it 'returns an error' do
          get :by_time, params: {}

          expect(response).to have_http_status(:bad_request)
          json_response = JSON.parse(response.body)
          expect(json_response['error']).to eq('Timestamp parameter is required')
        end
      end

      context 'when timestamp is outside the 24 hour range' do
        it 'returns an error with 404 status' do
          timestamp = (Time.now - 2.days).to_i
          get :by_time, params: { timestamp: timestamp }

          expect(response).to have_http_status(:not_found) # Changed from :success to :not_found
          json_response = JSON.parse(response.body)
          expect(json_response['error']).to eq('The timestamp is outside the 24 hour range')
        end
      end
    end
  end
end
