# frozen_string_literal: true

require 'nokogiri'

module Wataridori
  class LinkReplacer
    def initialize(rule)
      @rule = rule
    end

    def replaced_body_md(post)
      links(post).inject(post.body_md) do |body_md, link|
        next body_md unless rule.target?(link)

        if rule.post_relative_link?(link)
          body_md.gsub(/\(\w*#{link}\w*\)/, "(#{rule.replaced(link)})")
        else
          body_md.gsub(link, rule.replaced(link))
        end
      end
    end

    private

    attr_reader :rule

    def links(post)
      Nokogiri::HTML.parse(post.body_html).css('a').map { |link| link['href'] }
    end
  end
end
