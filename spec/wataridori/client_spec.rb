# frozen_string_literal: true

RSpec.describe Wataridori::Client do
  let(:from_client) { double('client', current_team: 'from') }
  let(:to_client) { double('client', current_team: 'to') }

  before do
    allow(to_client).to receive(:merge_user) do |data|
      data.merge('user' => data.created_by.screen_name)
    end
    allow(to_client).to receive(:merge_updated_by) do |data|
      data.merge('updated_by' => data.created_by.screen_name)
    end
  end

  let(:post1) do
    { 'number' => 1, 'body_md' => '# section1', 'created_by' => { 'screen_name' => 'alice' },
      'url' => 'https://from.esa.io/posts/1', 'comments' => [comment1, comment2] }
  end
  let(:post2) do
    { 'number' => 2, 'body_md' => '## section2', 'created_by' => { 'screen_name' => 'bob' },
      'url' => 'https://from.esa.io/posts/2', 'comments' => [] }
  end
  let(:comment1) do
    { 'body_md' => 'comment1', 'created_by' => { 'screen_name' => 'alice' },
      'url' => 'https://from.esa.io/posts/1#comment-3' }
  end
  let(:comment2) do
    { 'body_md' => 'comment2', 'created_by' => { 'screen_name' => 'bob' },
      'url' => 'https://from.esa.io/posts/1#comment-4' }
  end

  let(:copy_results) do
    [
      Wataridori::CopyResult.create_by_hash(
        from: { number: 1, url: 'https://from.esa.io/posts/1' },
        to: { number: 10, url: 'https://to.esa.io/posts/10' }
      ),
      Wataridori::CopyResult.create_by_hash(
        from: { number: 2, url: 'https://from.esa.io/posts/2' },
        to: { number: 20, url: 'https://to.esa.io/posts/20' }
      )
    ]
  end

  subject { described_class.new(from_client: from_client, to_client: to_client, logger: Logger.new('/dev/null')) }

  describe '#bulk_copy' do
    before do
      # 記事の作成
      allow(to_client).to receive(:create_post)
        .with(post1.merge('user' => 'alice'))
        .and_return(Wataridori::Esa::Response.new('number' => 10, 'url' => 'https://to.esa.io/posts/10'))
      allow(to_client).to receive(:create_post)
        .with(post2.merge('user' => 'bob'))
        .and_return(Wataridori::Esa::Response.new('number' => 20, 'url' => 'https://to.esa.io/posts/20'))
      # コメントの作成
      allow(to_client).to receive(:create_comment)
        .with(10, comment1.merge('user' => 'alice'))
        .and_return(Wataridori::Esa::Response.new('url' => 'https://to.esa.io/posts/10#comment-30'))
      allow(to_client).to receive(:create_comment)
        .with(10, comment2.merge('user' => 'bob'))
        .and_return(Wataridori::Esa::Response.new('url' => 'https://to.esa.io/posts/10#comment-40'))
    end

    context 'ページネーションなし' do
      it 'カテゴリ以下の記事を取ってきて、それぞれをpostする' do
        # 記事の取得
        allow(from_client).to receive(:posts)
          .with(q: 'in:path/to/category', per_page: 10, page: 1,
                include: 'comments', order: 'asc', sort: 'created')
          .and_return(Wataridori::Esa::Response.new('posts' => [post1, post2]))

        expect(subject.bulk_copy('path/to/category', per_page: 10)).to eq(copy_results)
      end
    end

    context 'ページネーションあり' do
      it 'カテゴリ以下の記事を取ってきて、それぞれをpostする' do
        # 記事の取得
        allow(from_client).to receive(:posts)
          .with(q: 'in:path/to/category', per_page: 1, page: 1,
                include: 'comments', order: 'asc', sort: 'created')
          .and_return(Wataridori::Esa::Response.new('posts' => [post1], 'next_page' => 2))
        allow(from_client).to receive(:posts)
          .with(q: 'in:path/to/category', per_page: 1, page: 2,
                include: 'comments', order: 'asc', sort: 'created')
          .and_return(Wataridori::Esa::Response.new('posts' => [post2]))

        expect(subject.bulk_copy('path/to/category', per_page: 1)).to eq(copy_results)
      end
    end
  end

  describe '#replace_link' do
    let(:post10) do
      { 'number' => 1, 'body_md' => '[link](/posts/2)',
        'body_html' => '<a href="/posts/2">link</a>',
        'created_by' => { 'screen_name' => 'alice' },
        'url' => 'https://from.esa.io/1', 'comments' => [comment10] }
    end
    let(:post20) do
      { 'number' => 2, 'body_md' => 'no replace',
        'body_html' => 'no replace',
        'created_by' => { 'screen_name' => 'bob' },
        'url' => 'https://from.esa.io/2', 'comments' => [] }
    end
    let(:comment10) do
      { 'id' => 111, 'body_md' => '[link](/posts/1)',
        'body_html' => '<a href="/posts/1">link</a>',
        'created_by' => { 'screen_name' => 'bob' },
        'url' => 'https://from.esa.io/posts/10#comment-1' }
    end

    it '各URLを置換する修正リクエストを投げる' do
      allow(to_client).to receive(:post)
        .with(10, include: :comments).once.and_return(Wataridori::Esa::Response.new(post10))
      expect(to_client).to receive(:update_post)
        .with(10, include('body_md' => '[link](/posts/20)')).once
      expect(to_client).to receive(:update_comment)
        .with(111, include('body_md' => '[link](/posts/10)')).once
      allow(to_client).to receive(:post)
        .with(20, include: :comments).once.and_return(Wataridori::Esa::Response.new(post20))
      expect(to_client).to receive(:update_post)
        .with(20, include('body_md' => 'no replace')).once

      subject.replace_links(copy_results)
    end
  end
end
