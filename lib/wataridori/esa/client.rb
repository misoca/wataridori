# frozen_string_literal: true

require 'esa'
require 'retriable'

module Wataridori
  module Esa
    # Esa::Clientのwrapper
    # リトライやリクエストレートの制御などを行う
    class Client
      def initialize(access_token:, current_team:)
        @original = ::Esa::Client.new(access_token: access_token, current_team: current_team)
        @ratelimit = Ratelimit.no_wait
      end

      def current_team
        original.current_team
      end

      def merge_user(data, writer_header: false)
        data.merge(
          'user' => valid_screen_name(data.created_by.screen_name),
          'body_md' => (writer_header ? writer_header(data.created_by.screen_name) : '') + data.body_md
        )
      end

      def merge_updated_by(data)
        data.merge('updated_by' => valid_screen_name(data.created_by.screen_name))
      end

      def writer_header(name)
        return '' if member?(name)

        "*written by #{name}*\n"
      end

      def valid_screen_name(name)
        member?(name) ? name : 'esa_bot'
      end

      def member?(name)
        @screen_names ||= with_all_pages(:members, per_page: 100) do |response|
          response.members.map(&:screen_name)
        end
        @screen_names.member?(name)
      end

      def with_all_pages(method, params = {})
        (1..Float::INFINITY).inject([]) do |acc, page|
          response = send(method, params.merge(page: page))
          result = yield response
          break acc + result if response.last_page?

          acc + result
        end
      end

      private

      attr_reader :original, :ratelimit

      def method_missing(method_name, *args)
        return call_original(method_name, *args) if original.respond_to?(method_name)

        super
      end

      def call_original(method_name, *args)
        sleep ratelimit.second_for_next_request
        Retriable.retriable do
          original.send(method_name, *args).yield_self do |response|
            @ratelimit = Ratelimit.from_headers(response.headers)
            Wataridori::Esa::Response.new(response.body)
          end
        end
      end

      def respond_to_missing?(method_name, *)
        original.respond_to?(method_name) || super
      end
    end
  end
end
