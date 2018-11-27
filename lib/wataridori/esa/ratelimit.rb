# frozen_string_literal: true

module Wataridori
  module Esa
    class Ratelimit
      class << self
        def from_headers(headers)
          new(headers['X-Ratelimit-Remaining'].to_i, Time.at(headers['X-Ratelimit-Reset'].to_i))
        end

        # 初回リクエスト用のダミーRatelimitを生成する
        def no_wait
          new(1, Time.at(0))
        end
      end

      def initialize(remaining, reset_at)
        @remaining = remaining
        @reset_at = reset_at
      end

      def second_for_next_request(current = Time.now)
        return 0 if remaining.positive?
        return 0 if reset_at <= current

        reset_at.to_i - current.to_i
      end

      attr_reader :remaining, :reset_at
    end
  end
end
