# frozen_string_literal: true

RSpec.describe Wataridori::Esa::Ratelimit do
  describe 'from_headers' do
    let(:headers) { { 'X-Ratelimit-Remaining' => '123', 'X-Ratelimit-Reset' => '456' } }
    subject { described_class.from_headers(headers) }
    it { is_expected.to have_attributes(remaining: 123, reset_at: Time.at(456)) }
  end

  describe 'no_wait' do
    subject { described_class.no_wait }
    it { is_expected.to have_attributes(remaining: be > 0, reset_at: Time.at(0)) }
  end

  describe 'second_for_next_request' do
    let(:current) { Time.now }

    shared_examples 'API残とreset_atによってsleep時間が決まる' do |remaining, reset_at_diff, seconds|
      subject { described_class.new(remaining, current + reset_at_diff).second_for_next_request(current) }
      describe "API残 #{remaining}、reset_atが #{reset_at_diff}秒後のとき" do
        it { is_expected.to eq(seconds) }
      end
    end

    it_behaves_like 'API残とreset_atによってsleep時間が決まる', 1, 0, 0
    it_behaves_like 'API残とreset_atによってsleep時間が決まる', 1, 1, 0
    it_behaves_like 'API残とreset_atによってsleep時間が決まる', 0, 0, 0
    it_behaves_like 'API残とreset_atによってsleep時間が決まる', 0, 1, 1
    it_behaves_like 'API残とreset_atによってsleep時間が決まる', 0, 123, 123
  end
end
