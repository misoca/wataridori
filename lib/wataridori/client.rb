module Wataridori
  class Client
    def initialize(from_client:, to_client:)
      @from_client = from_client
      @to_client = to_client
    end

    def self.from_teamname(token:, from:, to:)
      new(from_client: Esa::Client.new(access_token: token, current_team: from),
          to_client: Esa::Client.new(access_token: token, current_team: to))
    end

    def bulk_copy(category, per_page: 3)
      posts = from_client.posts(q: "in:#{category}", per_page: per_page, include: 'comments')
      posts.body['posts'].each do |post|
        res = to_client.create_post(post.merge(user: post['created_by']['screen_name']))
        post_number = res.body['number']
        post['comments'].each do |comment|
          to_client.create_comment(post_number, body_md: comment['body_md'], user: comment['created_by']['screen_name'])
        end
      end.count
    end

    private

    attr_reader :from_client, :to_client
  end
end
