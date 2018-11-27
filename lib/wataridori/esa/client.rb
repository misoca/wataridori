# frozen_string_literal: true

module Wataridori
  module Esa
    # Esa::Clientのwrapper
    # リトライやリクエストレートの制御などを行う
    class Client
      def initialize(access_token:, current_team:)
        @original = ::Esa::Client.new(access_token: access_token, current_team: current_team)
      end

      private

      def method_missing(method_name, *args)
        return @original.send(method_name, *args) if @original.respond_to?(method_name)

        super
      end

      def respond_to_missing?(method_name)
        @original.respond_to?(method_name)
      end
    end
  end
end
