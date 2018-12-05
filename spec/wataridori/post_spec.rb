# frozen_string_literal: true

RSpec.describe Wataridori::Post do
  let(:rule) do
    Wataridori::LinkReplacementRule.new(
      'from',
      'to',
      [
        Wataridori::CopyResult.create_by_hash(
          from: { number: 1, url: 'https://from.esa.io/posts/1' },
          to: { number: 10, url: 'https://to.esa.io/posts/10' }
        )
      ]
    )
  end

  describe 'replace_links' do
    let(:raw_post) { Wataridori::Esa::Response.new(number: 2, body_md: body_md, body_html: body_html) }
    let(:post) { described_class.new(raw_post) }
    subject { post.replace_links(rule).to_h.body_md }

    context '置換対象のリンクが含まれない場合' do
      let(:body_md) { '# Getting Started' }
      let(:body_html) { '<h1 id=\"1-0-0\" name=\"1-0-0\">\n<a class=\"anchor\" href=\"#1-0-0\"><i class=\"fa fa-link\"></i><span class=\"hidden\" data-text=\"Getting Started\"> &gt; Getting Started</span></a>Getting Started</h1>\n' } # rubocop:disable Metrics/LineLength

      it { is_expected.to eq(body_md) }
    end

    context '移行した記事の相対パスが含まれる場合' do
      let(:body_md) { '[移行対象へのリンク](/posts/1)' }
      let(:body_html) { '<a href="/posts/1">移行対象へのリンク</a>' }

      it { is_expected.to eq('[移行対象へのリンク](/posts/10)') }
    end

    context '移行した記事のフルパスが含まれる場合' do
      let(:body_md) { '移行対象へのフルパスリンク https://from.esa.io/posts/1' }
      let(:body_html) { '移行対象へのフルパスリンク <a href="https://from.esa.io/posts/1">https://from.esa.io/posts/1</a>' }

      it { is_expected.to eq('移行対象へのフルパスリンク https://to.esa.io/posts/10') }
    end

    context '移行していない記事の相対パスが含まれる場合' do
      let(:body_md) { '[移行対象外へのリンク](/posts/5)' }
      let(:body_html) { '<a href="/posts/5">移行対象外へのリンク</a>' }

      it { is_expected.to eq('[移行対象外へのリンク](https://from.esa.io/posts/5)') }
    end

    context '移行していない記事のフルパスが含まれる場合' do
      let(:body_md) { '移行対象外へのフルパスリンク https://from.esa.io/posts/5' }
      let(:body_html) { '移行対象外へのフルパスリンク <a href="https://from.esa.io/posts/5">https://from.esa.io/posts/5</a>' }

      it { is_expected.to eq('移行対象外へのフルパスリンク https://from.esa.io/posts/5') }
    end
  end
end
