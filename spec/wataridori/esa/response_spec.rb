# frozen_string_literal: true

require 'esa'

RSpec.describe Wataridori::Esa::Response do
  subject { described_class.new(posts: %i[post1 post2]) }
  it 'ドットアクセスできる' do
    expect(subject.posts).to eq(%i[post1 post2])
  end
end
