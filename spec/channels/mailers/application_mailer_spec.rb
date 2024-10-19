# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationMailer, type: :mailer do
  it 'is a subclass of ActionMailer::Base' do
    expect(described_class).to be < ActionMailer::Base
  end
end
