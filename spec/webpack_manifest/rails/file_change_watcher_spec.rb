# frozen_string_literal: true

require 'fileutils'

RSpec.describe WebpackManifest::Rails::FileChangeWatcher do
  describe '#record_digest' do
    subject { described_class.new(['tmp/file_change_watcher/*'], digest_path).record_digest }

    let(:digest_path) { 'tmp/digest' }

    before do
      FileUtils.mkdir_p('tmp/file_change_watcher')
      File.write('tmp/file_change_watcher/a', 'a')
      File.write('tmp/file_change_watcher/b', 'b')
    end

    after do
      FileUtils.rm_f(digest_path)
      FileUtils.rm_rf('tmp/file_change_watcher')
    end

    it 'saves the digest to the file' do
      subject
      expect(File.read(digest_path)).to eq '78d884924aed108c5956f3ef14fc28c324d0e416'
    end
  end

  describe '#fresh?' do
    subject { watcher.fresh? }

    let(:watcher){ described_class.new(['tmp/file_change_watcher/*'], digest_path) }
    let(:digest_path) { 'tmp/digest' }

    context 'when the file to store digest does not exist' do
      it 'always returns false' do
        expect(subject).to eq false
      end
    end

    context 'when watched files are up to date' do
      before { watcher.record_digest }
      after { FileUtils.rm_f(digest_path) }
 
      it { is_expected.to eq true }
    end

    context 'when watched files are out to date' do
      before do
        watcher.record_digest
        # Create a file to make state stale
        FileUtils.mkdir_p('tmp/file_change_watcher')
        File.write('tmp/file_change_watcher/a', 'a')
      end

      after do
        FileUtils.rm_f(digest_path)
        FileUtils.rm_rf('tmp/file_change_watcher')
      end

      it { is_expected.to eq false }
    end
  end
end
