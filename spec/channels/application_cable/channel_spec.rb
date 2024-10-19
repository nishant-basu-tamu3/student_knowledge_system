# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationCable::Channel, type: :channel do
  it 'is a subclass of ActionCable::Channel::Base' do
    expect(described_class).to be < ActionCable::Channel::Base
  end
end
