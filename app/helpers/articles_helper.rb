module ArticlesHelper
  require 'nokogiri'
  require 'open-uri'
  require 'time'

  URLS = ['https://www.gov.br/turismo/pt-br/secretaria-especial-da-cultura/assuntos/noticias'.freeze,
          'https://www.gov.br/cidadania/pt-br/noticias-e-conteudos/desenvolvimento-social/noticias-desenvolvimento-social'.freeze].freeze
  FOLLOWUP_SELECTORS = ['//article//header//span//a[@class=" state-published url"]/@href'.freeze,
                        '//article//div//h2//a[@class="summary url"]/@href'.freeze].freeze
  PAGINATION_SELECTOR = '//ul[@class="paginacao listingBar"]//li//a[@class="proximo"]/@href'.freeze
  TITLE_SELECTOR = '//article//h1[@class="documentFirstHeading"]'.freeze
  PUBLISH_DATE_SELECTOR = '//div[@class="documentByLine"]//span[@class="documentPublished"]//span[@class="value"]'.freeze
  TEXT_NODE_SELECTOR = '//div[@id="parent-fieldname-text"]'.freeze # keep raw, hydrate to html?

  def update_articles(source)
    crawler(URLS[source], FOLLOWUP_SELECTORS[source])
  end

  private

  def crawler(url, followup_selector)
    # An initial url and xpath selector for links to follow.
    # Parse url
    doc = get_doc(url)
    # Get links to the actual news
    articles_links = get_list(doc, followup_selector)
    # Access each link and get the data we need
    data_array = extract_article_data(articles_links)
    # Build
    build_articles(url, data_array)
    # Fire this again on the next page
    next_page = get_element(doc, PAGINATION_SELECTOR)&.text
    crawler(next_page, followup_selector) if next_page
  end

  def extract_article_data(articles_links)
    articles_links.map do |link|
      # Access the page for the specific link. This is the page with the data we want
      article_page = get_doc(link.value)
      title = get_element(article_page, TITLE_SELECTOR).text
      publish_date = get_element(article_page, PUBLISH_DATE_SELECTOR).text
      content = get_element(article_page, TEXT_NODE_SELECTOR).text
      # Map each group of attributes to a hash, which will be an element in the returned array
      { url: link, title: title, publish_date: publish_date, content: content }
    end
  end

  def build_articles(source, data_array)
    data_array.each do |attrs|
      # TODO: Bounce early if url in Article.all.urls (or whatever the syntax is)
      Article.create(title: attrs.title, publish_date: clean_date(attrs.publish_date),
                     content: clean_content(attrs.content), collect_date: Time.now, source: source)
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
end
