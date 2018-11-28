# frozen_string_literal: true

require 'hashie'

module Wataridori
  module Esa
    class Response < Hashie::Mash
      def last_page?
        next_page.nil?
      end
    end
  end
end
