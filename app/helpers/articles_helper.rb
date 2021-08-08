module ArticlesHelper
  require 'nokogiri'
  require 'open-uri'
  require 'time'
  require 'set'

  URLS = { 'Cultura': 'https://www.gov.br/turismo/pt-br/secretaria-especial-da-cultura/assuntos/noticias'.freeze,
           'Desenvolvimento Social': 'https://www.gov.br/cidadania/pt-br/noticias-e-conteudos/desenvolvimento-social/noticias-desenvolvimento-social'.freeze }.freeze
  FOLLOWUP_SELECTORS = { 'Cultura': '//article//header//span//a[@class=" state-published url"]/@href'.freeze,
                         'Desenvolvimento Social': '//article//div//h2//a[@class="summary url"]/@href'.freeze }.freeze
  PAGINATION_SELECTOR = '//ul[@class="paginacao listingBar"]//li//a[@class="proximo"]/@href'.freeze
  TITLE_SELECTOR = '//article//h1[@class="documentFirstHeading"]'.freeze
  PUBLISH_DATE_SELECTOR = '//div[@class="documentByLine"]//span[@class="documentPublished"]//span[@class="value"]'.freeze
  TEXT_NODE_SELECTOR = '//div[@id="parent-fieldname-text"]'.freeze # keep raw, hydrate to html?

  def update_articles(source)
    @persisted = Article.select('url').map(&:url).to_set
    crawler(URLS[source.to_sym], FOLLOWUP_SELECTORS[source.to_sym], source)
  end

  private

  def crawler(url, followup_selector, source)
    # An initial url and xpath selector for links to follow.
    # Parse url
    parsed_page = get_doc(url)
    # Get links to the actual news
    articles_links = get_list(parsed_page, followup_selector)
    # Filter list so we only deal with new URLs
    filtered_links = filter_links(articles_links)
    # Access each link and get the data we need
    data_array = extract_article_data(filtered_links)
    # Build
    build_articles(source, data_array)
    # Fire this again on the next page
    next_page = get_element(parsed_page, PAGINATION_SELECTOR)&.text
    crawler(next_page, followup_selector, source) if next_page
  end

  def extract_article_data(filtered_links)
    filtered_links.map do |link|
      # Access the page for the specific link. This is the page with the data we want
      article_page = get_doc(link)
      title = get_element(article_page, TITLE_SELECTOR).text
      publish_date = get_element(article_page, PUBLISH_DATE_SELECTOR).text
      content = get_element(article_page, TEXT_NODE_SELECTOR).text
      # Map each group of attributes to a hash, which will be an element in the returned array
      { url: link, title: title, publish_date: publish_date, content: content }
    end
  end

  def build_articles(source, data_array)
    data_array.each do |attrs|
      Article.create(title: attrs[:title], publish_date: clean_date(attrs[:publish_date]),
                     content: clean_content(attrs[:content]), collect_date: Time.now, source: source, url: attrs[:url])
    end
  end

  ######### START NOKOGIRI

  def get_doc(url)
    Nokogiri::HTML(URI.open(url), nil, 'utf-8')
  end

  def get_list(doc, selector)
    doc.xpath(selector)
  end

  def get_element(doc, selector)
    doc.at_xpath(selector)
  end

  ######## END NOKOGIRI

  def clean_content(string)
    string.strip
  end

  def clean_date(date)
    Time.parse(date)
  end

  def filter_links(arr)
    arr.map(&:value).to_set - @persisted
  end
end
