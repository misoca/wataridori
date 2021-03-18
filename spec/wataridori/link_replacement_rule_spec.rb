# frozen_string_literal: true

RSpec.describe Wataridori::LinkReplacementRule do
  let(:rule) do
    described_class.new(
      'from',
      'to',
      [
        Wataridori::CopyResult.create_by_hash(
          from: { number: 1, url: 'https://from.esa.io/posts/1' },
          to: { number: 10, url: 'http://to.esa.io/posts/10' }
        )
      ]
    )
  end

  describe '#target?' do
    subject { rule.target?(link) }

    context '移行対象記事の相対パス' do
      let(:link) { '/posts/1' }

      it { is_expected.to be_truthy }
    end

    context '移行対象記事の絶対パス' do
      let(:link) { 'https://from.esa.io/posts/1' }

      it { is_expected.to be_truthy }
    end

    context '移行対象外記事の相対パス' do
      let(:link) { '/posts/5' }

      it { is_expected.to be_truthy }
    end

    context '移行対象外記事の絶対パス' do
      let(:link) { 'https://from.esa.io/posts/5' }

      it { is_expected.to be_falsey }
    end

    context '移行対象元のpath' do
      let(:link) { 'https://from.esa.io/#path=%2FArchived' }

      it { is_expected.to be_truthy }
    end

    context '移行対象元のquery' do
      let(:link) { 'https://from.esa.io/posts?q=test' }

      it { is_expected.to be_truthy }
    end

    context '関係のないURL' do
      let(:link) { 'https://example.com/' }

      it { is_expected.to be_falsey }
    end
  end

  describe '#replaced' do
    subject { rule.replaced(link) }

    context '移行対象記事の相対パス' do
      let(:link) { '/posts/1' }

      it { is_expected.to eq('/posts/10') }
    end

    context '移行対象記事の絶対パス' do
      let(:link) { 'https://from.esa.io/posts/1' }

      it { is_expected.to eq('http://to.esa.io/posts/10') }
    end

    context '移行対象外記事の相対パス' do
      let(:link) { '/posts/5' }

      it { is_expected.to eq('https://from.esa.io/posts/5') }
    end

    context '移行対象外記事の絶対パス' do
      let(:link) { 'https://from.esa.io/posts/5' }

      it { is_expected.to eq('https://from.esa.io/posts/5') }
    end

    context '移行対象元のpath' do
      let(:link) { 'https://from.esa.io/#path=%2FArchived' }

      it { is_expected.to eq('https://to.esa.io/#path=%2FArchived') }
    end

    context '移行対象元のquery' do
      let(:link) { 'https://from.esa.io/posts?q=test' }

      it { is_expected.to eq('https://to.esa.io/posts?q=test') }
    end

    context '関係のないURL' do
      let(:link) { 'https://example.com/' }

      it { is_expected.to eq('https://example.com/') }
    end
  end

  describe '#relative?' do
    it { expect(rule).to be_post_relative_link('/posts/1') }
    it { expect(rule).not_to be_post_relative_link('https://from.esa.io/posts/1') }
  end
end
