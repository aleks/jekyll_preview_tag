#
#  Jekyll Preview Tag - Generate link previews inside you articles.
#  This plugin uses nokogiri and ruby-readability to create a preview and create a local cached snippet.
#  By: Aleks Maksimow, Kaffeezucht.de
#
#  Required Gems/Libraries: nokogiri, open-uri, ruby-readability, digest
#
#  Usage:
# 
#  1. Generate a new folder called "_cache" in your Jekyll directory. 
#     This will hold all linked snippets, so you don't need to regenerate them on every regeneration of your site.
# 
#  2. Use the following link syntax: 
# 
#     {% preview http://example.com/some-article.html %}
# 
#  3. In case we can't fetch the Title from a linksource, you can set it manually:
#
#     {% preview "Some Article" http://example.com/some-article.html %}
# 
#  Feel free to send a pull-request: https://github.com/aleks/jekyll_preview_tag
#

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'readability'
require 'digest'

module Jekyll
  class PreviewTag < Liquid::Tag
    def initialize(tag_name, tag_text, tokens)
      super

      @link_url = tag_text.scan(/https?:\/\/[\S]+/).first
      @link_title = tag_text.scan(/\"(.*)\"/)[0].to_s.gsub(/\"|\[|\]/,'')

      build_preview_content
    end

    def build_preview_content
      if cache_exists?(@link_url)
        @preview_content = read_cache(@link_url).to_s
      else
        source = Nokogiri::HTML(open(@link_url))

        @preview_text = get_content(source)
        if @link_title == ''
          @preview_title = get_content_title(source)
        else
          @preview_title = @link_title
        end

        @preview_content = "<h4><a href='#{@link_url}' target='_blank'>#{@preview_title.to_s}</a></h4><small>#{@preview_text.to_s}</small>"

        write_cache(@link_url, @preview_content)
      end
    end

    def render(context)
      %|#{@preview_content}|
    end

    def get_content(source)
      cleanup(Readability::Document.new(source, :tags => %w[]).content)
    end

    def get_content_title(source)
      if source.css('.entry-title').first
        cleanup(source.css('.entry-title').first.content)
      elsif source.css('.title').first
        cleanup(source.css('.title').first.content)
      elsif source.css('.article_title').first
        cleanup(source.css('.article_title').first.content)
      elsif source.css('h1').first
        cleanup(source.css('h1').first.content)
      elsif source.css('h2').first
        cleanup(source.css('h2').first.content)
      elsif source.css('h3').first
        cleanup(source.css('h3').first.content)
      end
    end

    def cleanup(content)
      content = content.gsub(/\t/,'')
      if content.size < 200
        content
      else
        content[0..200] + '...'
      end
    end

    def cache_key(link_url)
      Digest::MD5.hexdigest(link_url)
    end

    def cache_exists?(link_url)
      File.exist?("_cache/#{cache_key(link_url)}")
    end

    def write_cache(link_url, content)
      File.open("_cache/#{cache_key(link_url)}", 'w') { |f| f.write(content) }
    end

    def read_cache(link_url)
      File.read("_cache/#{cache_key(link_url)}")
    end
    
  end
end

Liquid::Template.register_tag('preview', Jekyll::PreviewTag)
