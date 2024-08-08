# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Accuweather::DayWeatherConditions do
  subject(:day_conditions) { described_class.call }

  let(:client) { instance_double(Accuweather::Client) }
  let(:response_result) do
    [
      {
        'EpochTime' => 1_723_021_240,
        'Temperature' => {
          'Metric' => {
            'Value' => 22.1
          }
        }
      },
      {
        'EpochTime' => 1_723_243_960,
        'Temperature' => {
          'Metric' => {
            'Value' => 20.1
          }
        }
      },
      {
        'EpochTime' => 1_723_543_010,
        'Temperature' => {
          'Metric' => {
            'Value' => 19.8
          }
        }
      }
    ]
  end

  before do
    allow(Accuweather::Client).to receive(:new).and_return(client)
    allow(client).to receive(:historical_conditions).and_return(response_result)
  end

  it 'creates condition records', :aggregate_failures do
    result = day_conditions

    expect(result[0][:temperature]).to eq(22.1)
    expect(result[0][:timestamp]).to eq(1_723_021_240)

    expect(result[1][:temperature]).to eq(20.1)
    expect(result[1][:timestamp]).to eq(1_723_243_960)

    expect(result[2][:temperature]).to eq(19.8)
    expect(result[2][:timestamp]).to eq(1_723_543_010)
  end
end
