# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Accuweather::CurrentWeatherConditions do
  subject(:current_conditions) { described_class.call }

  let(:client) { instance_double(Accuweather::Client) }
  let(:response_result) do
    [
      {
        'EpochTime' => 1_723_020_960,
        'Temperature' => {
          'Metric' => {
            'Value' => 18.4
          }
        }
      }
    ]
  end

  before do
    allow(Accuweather::Client).to receive(:new).and_return(client)
    allow(client).to receive(:current_conditions).and_return(response_result)
  end

  it 'creates condition record', :aggregate_failures do
    result = current_conditions
    expect(result[:temperature]).to eq(18.4)
    expect(result[:timestamp]).to eq(1_723_020_960)
  end
end
