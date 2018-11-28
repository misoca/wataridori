# frozen_string_literal: true

module Wataridori
  class Client
    def initialize(from_client:, to_client:)
      @from_client = from_client
      @to_client = to_client
    end

    def self.from_teamname(token:, from:, to:)
      new(from_client: Wataridori::Esa::Client.new(access_token: token, current_team: from),
          to_client: Wataridori::Esa::Client.new(access_token: token, current_team: to))
    end

    def bulk_copy(category, per_page: 3)
      target_posts(category, per_page).each do |post|
        to_client.create_post(post.merge('user' => post.created_by.screen_name)).tap do |created_post|
          bulk_copy_comments(post.comments, created_post.number)
        end
      end.count
    end

    private

    def bulk_copy_comments(comments, post_number)
      comments.each do |comment|
        to_client.create_comment(post_number, 'body_md' => comment.body_md, 'user' => comment.created_by.screen_name)
      end
    end

    attr_reader :from_client, :to_client

    def target_posts(category, per_page)
      (1..Float::INFINITY).inject([]) do |posts, page|
        response = from_client.posts(posts_params(category, page, per_page))
        break posts + response.posts if response.last_page?

        posts + response.posts
      end
    end

    def posts_params(category, page, per_page)
      {
        q: "in:#{category}",
        page: page,
        per_page: per_page,
        include: 'comments',
        sort: 'created',
        order: 'asc'
      }
    end
  end
end
