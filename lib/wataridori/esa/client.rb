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

      def merge_user(data)
        data.merge('user' => valid_screen_name(data.created_by.screen_name))
      end

      def merge_updated_by(data)
        data.merge('updated_by' => valid_screen_name(data.created_by.screen_name))
      end

      def valid_screen_name(name)
        @screen_names ||= members.members.map(&:screen_name)
        @screen_names.member?(name) ? name : 'esa_bot'
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
