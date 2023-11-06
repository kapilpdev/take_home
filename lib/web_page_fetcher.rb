require 'nokogiri'
require './lib/web_page'

class WebPageFetcher
  def initialize(urls, metadata_mode)
    @metadata_mode = metadata_mode
    @urls = urls
  end

  def fetch_pages(url)
    page = WebPage.new(url)
    page.fetch
    save_assets(url)
    fetch_metadata(page, url) if @metadata_mode
  rescue StandardError => e
    display_error(url, e)
  end

  def fetch_metadata(page, url)
    num_links, num_images, last_fetch = page.metadata
    display_metadata(url, num_links, num_images, last_fetch)
  rescue StandardError => e
    display_error(url, e)
  end

  def process_urls
    urls_to_process = @metadata_mode ? @urls : @urls.reject { |arg| arg == '--metadata' }
    urls_to_process.each { |url| fetch_pages(url) }
  end

  def save_assets(url)
    page = Nokogiri::HTML(URI.open(url))
    host_uri = URI.parse(url)
    FileUtils.mkdir_p(File.join(host_uri.host, "images")) unless Dir.exist?("#{host_uri.host}/images")
    save_image(page, host_uri, url)
    File.write(File.join(host_uri.host, "#{host_uri.host}.html"), page.to_html)
  end

  private

  def display_metadata(url, num_links, num_images, last_fetch)
    puts "site: #{url}"
    puts "num_links: #{num_links}"
    puts "images: #{num_images}"
    puts "last_fetch: #{last_fetch}"
    puts
  end

  def display_error(url, error)
    puts "Error fetching #{url}: #{error.message}"
  end

  def save_image(page, host_uri, url)
    page.css('img').each do |img|

      src = img['src']
      next if src.nil? || src.empty?

      img_url = URI.join(url, src).to_s

      img_path = File.join(host_uri.host,"/images", File.basename(src))
      img_fetch = File.join("images", File.basename(src))

      download_file(img_url, img_path)

      img['src'] = img_fetch
    end
  end

  def download_file(url, path)
    URI.open(url) do |u|
      File.open(path, 'wb') { |f| f.write(u.read) }
    end
  end
end
