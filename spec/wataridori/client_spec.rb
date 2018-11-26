# frozen_string_literal: true

RSpec.describe Wataridori::Client do
  DummyResponse = Struct.new(:body)

  let(:from_client) { double }
  let(:to_client) { double }

  let(:post1) do
    { 'number' => 1, 'body_md' => '# section1', 'created_by' => { 'screen_name' => 'alice' },
      'comments' => [comment1, comment2] }
  end
  let(:post2) do
    { 'number' => 2, 'body_md' => '## section2', 'created_by' => { 'screen_name' => 'bob' }, 'comments' => [] }
  end
  let(:comment1) { { 'body_md' => 'comment1', 'created_by' => { 'screen_name' => 'alice' } } }
  let(:comment2) { { 'body_md' => 'comment2', 'created_by' => { 'screen_name' => 'bob' } } }

  subject { described_class.new(from_client: from_client, to_client: to_client) }

  describe '#bulk_copy' do
    it 'カテゴリ以下の記事を取ってきて、それぞれをpostする' do
      # 記事の取得
      allow(from_client).to receive(:posts)
        .with(q: 'in:path/to/category', per_page: 10, include: 'comments', order: 'asc', page: 1, sort: 'created')
        .and_return(DummyResponse.new('posts' => [post1, post2]))
      # 記事の作成
      allow(to_client).to receive(:create_post)
        .with(post1.merge('user' => 'alice'))
        .and_return(DummyResponse.new('number' => 10))
      allow(to_client).to receive(:create_post)
        .with(post2.merge('user' => 'bob'))
        .and_return(DummyResponse.new('number' => 20))
      # コメントの作成
      allow(to_client).to receive(:create_comment)
        .with(10, 'body_md' => 'comment1', 'user' => 'alice')
      allow(to_client).to receive(:create_comment)
        .with(10, 'body_md' => 'comment2', 'user' => 'bob')

      subject.bulk_copy('path/to/category', per_page: 10)
    end
  end
end
