# frozen_string_literal: true

require 'esa'

RSpec.describe Wataridori::Esa::Client do
  let(:ratelimit_remaining) { '1' }
  let(:ratelimit_reset_at) { '0' }
  let(:client) { ::Esa::Client.new(access_token: 'dummy_token', current_team: 'dummy_team') }
  let(:response) do
    Struct.new(:headers, :body)
          .new({ 'X-Ratelimit-Remaining' => ratelimit_remaining, 'X-Ratelimit-Reset' => ratelimit_reset_at }, 'dummy_response')
  end

  subject do
    allow(::Esa::Client).to receive(:new).and_return(client)
    described_class.new(access_token: 'dummy_token', current_team: 'dummy_team')
  end

  describe 'method_missing' do
    context 'オリジナルのEsa::Clientに存在するメソッド' do
      it 'オリジナルを呼び出す' do
        expect(client).to receive(:posts).and_return(response)
        expect(subject.posts.body).to eq('dummy_response')
      end
    end

    context 'オリジナルのEsa::Clientに存在しないメソッド' do
      it 'NoMethodErrorになる' do
        expect { subject.unexist_method }.to raise_error(NoMethodError)
      end
    end
  end

  describe 'Ratelimit' do
    before do
      expect(client).to receive(:posts).and_return(response)
      subject.posts
    end

    context '前回リクエストでのRemainingが0かつreset_atが15分後' do
      let(:ratelimit_remaining) { '0' }
      let(:ratelimit_reset_at) { (Time.now + 15 * 60).to_i.to_s }

      it '15分程度sleepする' do
        # 実行時に数秒の誤差が入りうるので、14分以上のsleepであることを確認する
        expect(subject).to receive(:sleep).with(be >= 14 * 60).and_return(0)
        expect(client).to receive(:members).and_return(response)
        subject.members
      end
    end

    context '前回リクエストでのRemainingが0だがreset_atは1秒前' do
      let(:ratelimit_remaining) { '0' }
      let(:ratelimit_reset_at) { (Time.now - 1).to_i.to_s }

      it 'sleepしない' do
        expect(subject).to receive(:sleep).with(0).and_return(0)
        expect(client).to receive(:members).and_return(response)
        subject.members
      end
    end

    context '前回リクエストでのRemainingが1でreset_atは15分後' do
      let(:ratelimit_remaining) { '1' }
      let(:ratelimit_reset_at) { (Time.now + 15 * 60).to_i.to_s }

      it 'sleepしない' do
        expect(subject).to receive(:sleep).with(0).and_return(0)
        expect(client).to receive(:members).and_return(response)
        subject.members
      end
    end
  end
end
