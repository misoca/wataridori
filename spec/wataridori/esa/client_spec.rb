# frozen_string_literal: true

require 'esa'

RSpec.describe Wataridori::Esa::Client do
  let(:client) { ::Esa::Client.new(access_token: 'dummy_token', current_team: 'dummy_team') }

  subject do
    allow(::Esa::Client).to receive(:new).and_return(client)
    described_class.new(access_token: 'dummy_token', current_team: 'dummy_team')
  end

  describe 'method_missing' do
    context 'オリジナルのEsa::Clientに存在するメソッド' do
      it 'オリジナルを呼び出す' do
        expect(client).to receive(:posts).and_return('dummy_posts')
        expect(subject.posts).to eq('dummy_posts')
      end
    end

    context 'オリジナルのEsa::Clientに存在しないメソッド' do
      it 'NoMethodErrorになる' do
        expect { subject.unexist_method }.to raise_error(NoMethodError)
      end
    end
  end
end
