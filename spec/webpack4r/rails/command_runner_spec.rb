# frozen_string_literal: true

require 'logger'

RSpec.describe Webpack4r::Rails::CommandRunner do
  describe '#run' do
    subject { described_class.new({}, command, logger: logger, watcher: watcher).run }

    let(:logger) { Logger.new(nil) }
    let(:watcher) { nil }

    context 'when the command exit successfully' do
      let(:command) { 'echo hi && echo fail > /dev/stderr' }

      it 'sends messages to the logger' do
        expect(logger).to receive(:info).with('Start executing echo hi && echo fail > /dev/stderr, within .')
        expect(logger).to receive(:info).with('Executed successfully')
        expect(logger).to receive(:error).with("fail\n")
        subject
      end

      it { is_expected.to eq true }
    end

    context 'when the command exit unsuccessfully' do
      let(:command) { 'echo hi && echo fail > /dev/stderr && false' }

      it 'sends messages to the logger' do
        expect(logger).to receive(:info).with('Start executing echo hi && echo fail > /dev/stderr && false, within .')
        expect(logger).to receive(:error).with("Failed to execute:\nfail\n")
        subject
      end

      it { is_expected.to eq false }
    end

    context 'when watcher is given' do
      let(:command) { 'echo hi' }
      let(:watcher) { instance_double('Watcher') }

      context 'when the assets are up to date' do
        before do
          allow(watcher).to receive(:stale?).and_return(false)
        end

        it { is_expected.to eq true }
      end

      context 'when the assets are out of date, and command exits with successful' do
        before do
          allow(watcher).to receive(:stale?).and_return(true)
        end

        it 'saves the digest' do
          expect(watcher).to receive(:record_digest)
          expect(subject).to eq true
        end
      end
    end
  end

  describe '#run!' do
    subject { described_class.new({}, command, logger: logger, watcher: watcher).run! }

    let(:logger) { Logger.new(nil) }
    let(:watcher) { nil }

    context 'when the command exit unsuccessfully' do
      let(:command) { 'echo hi && echo fail > /dev/stderr && false' }

      it { expect { subject }.to raise_error described_class::UnsuccessfulError }
    end
  end
end
