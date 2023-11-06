require 'open-uri'
require 'nokogiri'

class WebPage
  attr_reader :url, :content

  def initialize(url)
    @url = url
  end

  def fetch
    @content = download_page
  end

  def save
    filename = "#{File.basename(url)}.html"
    write_content_to_file(filename, content)
    "Saved #{url} as #{filename}"
  end

  def metadata
    fetch
    num_links = count_elements('a')
    num_images = count_elements('img')
    last_fetch = formatted_time(Time.now.utc)
    [num_links, num_images, last_fetch]
  end

  private

  def count_elements(selector)
    page = Nokogiri::HTML(content)
    page.css(selector).count
  end

  def download_page
    URI.open(url).read
  end

  def write_content_to_file(filename, data)
    File.write(filename, data)
  end

  def formatted_time(time)
    time.strftime('%a %b %d %Y %H:%M UTC')
  end
end
