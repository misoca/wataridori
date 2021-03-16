# frozen_string_literal: true

require 'hashie'

module Wataridori
  CopyResult = Struct.new(:from, :to) do
    PostSummary = Struct.new(:number, :url) do # rubocop:disable Lint/ConstantDefinitionInBlock
      def self.by_post(post)
        new(post.number, post.url)
      end

      def self.by_hash(hash)
        new(hash[:number], hash[:url])
      end
    end

    def self.create_by_posts(from, to)
      new(PostSummary.by_post(from), PostSummary.by_post(to))
    end

    def self.create_by_hash(from:, to:)
      new(PostSummary.by_hash(from), PostSummary.by_hash(to))
    end

    def to_h
      { from: from.to_h, to: to.to_h }
    end
  end
end
