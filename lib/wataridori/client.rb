# frozen_string_literal: true

require 'logger'

module Wataridori
  class Client
    def initialize(from_client:, to_client:, logger: Logger.new(STDOUT))
      @from_client = from_client
      @to_client = to_client
      @logger = logger
    end

    def self.from_teamname(token:, from:, to:)
      new(from_client: Wataridori::Esa::Client.new(access_token: token, current_team: from),
          to_client: Wataridori::Esa::Client.new(access_token: token, current_team: to))
    end

    def bulk_copy(category, per_page: 3)
      logger.info("start bulk copy of category: #{category}")
      with_posts(category, per_page) { |post| copy_post(post) }
    end

    def replace_links(copy_results)
      logger.info('start replace links')
      rule = Wataridori::LinkReplacementRule.new(from_client.current_team, to_client.current_team, copy_results)
      copy_results.each do |result|
        replace_links_in_to_post(rule, result.to)
      end
    end

    private

    attr_reader :from_client, :to_client, :logger

    def with_posts(category, per_page)
      (1..Float::INFINITY).inject([]) do |acc, page|
        response = from_client.posts(posts_params(category, page, per_page))
        logger.info("copy posts: #{response.posts.map(&:number).join(',')}")
        result = response.posts.map { |post| yield post }
        break acc + result if response.last_page?

        acc + result
      end
    end

    def copy_post(post)
      created_post = to_client.create_post(to_client.merge_user(post))
      logger.info("  post created(from #{post.url} to #{created_post.url})")
      bulk_copy_comments(post.comments, created_post.number)
      CopyResult.create_by_posts(post, created_post)
    end

    def replace_links_in_to_post(rule, to)
      logger.info("replace url of #{to.url}")
      raw_post = to_client.post(to.number, include: :comments)
      post = Wataridori::Post.new(raw_post)
      post.replace_links(rule)
      to_client.update_post(to.number, to_client.merge_updated_by(post.to_h))
      logger.info('  post replaced')
      replace_links_in_to_comments(rule, raw_post.comments)
    end

    def replace_links_in_to_comments(rule, comments)
      comments.each do |comment|
        wrapped = Wataridori::Post.new(comment)
        wrapped.replace_links(rule)
        to_client.update_comment(comment.id, to_client.merge_user(wrapped.to_h))
        logger.info("  comment #{comment.url} replaced")
      end
    end

    def bulk_copy_comments(comments, post_number)
      comments.each do |comment|
        to_client.create_comment(
          post_number, to_client.merge_user(comment)
        ).tap do |created_comment|
          logger.info("  comment created(from #{comment.url} to #{created_comment.url})")
        end
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
