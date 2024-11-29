# frozen_string_literal: true

require 'rails_helper'

class TracingTestClass
  require 'utilities/tracing'
  include Tracing

  def perform(logger = Rails.logger)
    with_tracing 'my_message', logger do
      do_some_work
    end
  end

  def perform_with_error(logger = Rails.logger)
    with_tracing 'my_message', logger do
      do_some_work_with_error
    end
  end

  def do_some_work
    # doing some operation
    10 * 10
  end

  def do_some_work_with_error
    raise StandardError, 'Something went wrong'
  end
end

describe Tracing do
  describe '#with_tracing' do
    it 'traces the the code and returns the result' do
      expect(TracingTestClass.new.perform).to eq(100)
    end

    it 'writes two logs entries' do
      logger = instance_double(Logger)
      rails = class_double(Rails)
      allow(rails).to receive(:logger).and_return(logger)
      allow(logger).to receive(:info).and_return(nil)
      TracingTestClass.new.perform(logger)
      expect(logger).to have_received(:info).twice.with(any_args)
    end

    it 'catches and rethrows standard exceptions' do
      logger = instance_double(Logger)
      rails = class_double(Rails)
      allow(rails).to receive(:logger).and_return(logger)
      allow(logger).to receive(:info).and_return(nil)

      expect do
        TracingTestClass.new.perform_with_error(logger)
      end.to raise_error(StandardError)

      expect(logger).to have_received(:info).twice.with(any_args)
    end
  end
end
