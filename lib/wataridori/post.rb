# frozen_string_literal: true

require 'nokogiri'

module Wataridori
  class Post
    def initialize(post)
      @post = post
    end

    def replace_links(rule)
      post.body_md = links.inject(post.body_md) do |body_md, link|
        next body_md unless rule.target?(link)

        if rule.post_relative_link?(link)
          body_md.gsub(/\(\w*#{link}\w*\)/, "(#{rule.replaced(link)})")
        else
          body_md.gsub(link, rule.replaced(link))
        end
      end

      self
    end

    def to_h
      post
    end

    def to_request
      to_h.merge(
        'user' => post.created_by.screen_name
      )
    end

    private

    attr_reader :post

    def links
      Nokogiri::HTML.parse(post.body_html).css('a').map { |link| link['href'] }
    end
  end
end
