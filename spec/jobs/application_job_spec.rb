# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationJob, type: :job do
  it 'is a subclass of ActiveJob::Base' do
    expect(described_class).to be < ActiveJob::Base
  end
end
