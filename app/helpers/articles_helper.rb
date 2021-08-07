module ArticlesHelper
  require 'nokogiri'
  require 'open-uri'
  require 'time'

  URL_SEC = 'https://www.gov.br/turismo/pt-br/secretaria-especial-da-cultura/assuntos/noticias'.freeze
  URL_SDS = 'https://www.gov.br/cidadania/pt-br/noticias-e-conteudos/desenvolvimento-social/noticias-desenvolvimento-social'.freeze
  SEC_ARTICLE_LINKS_SELECTOR = '//article//header//span//a[@class=" state-published url"]/@href'.freeze
  SDS_ARTICLE_LINKS_SELECTOR = '//article//div//h2//a[@class="summary url"]/@href'.freeze
  PAGINATION_SELECTOR = '//ul[@class="paginacao listingBar"]//li//a[@class="proximo"]/@href'.freeze
  TITLE_SELECTOR = '//article//h1[@class="documentFirstHeading"]'.freeze
  PUBLISH_DATE_SELECTOR = '//div[@class="documentByLine"]//span[@class="documentPublished"]//span[@class="value"]'.freeze
  TEXT_NODE_SELECTOR = '//div[@id="parent-fieldname-text"]'.freeze # keep raw, hydrate to html?

  def crawler(url, followup_selector)
    # An initial url and xpath selector for links to follow.
    # Parse url
    doc = get_doc(url)
    # Get links to the actual news
    articles_links = get_list(doc, followup_selector)
    # Access each link and get the data we need
    extract_article_data(articles_links)
    # Fire this again on the next page
    next_page = get_element(doc, PAGINATION_SELECTOR)&.text
    crawler(next_page, followup_selector) if next_page
  end

  def build_article(title, publish_date, content)
    Article.new(title: title, publish_date: clean_date(publish_date), content: clean_content(content),
                collect_date: Time.now)
  end

  private

  def extract_article_data(articles_links)
    articles_links.each do |link|
      article_page = get_doc(link.value)
      title = get_element(article_page, TITLE_SELECTOR).text
      publish_date = get_element(article_page, PUBLISH_DATE_SELECTOR).text
      content = get_element(article_page, TEXT_NODE_SELECTOR).text
      build_article(title, publish_date, content)
    end
  end

  def get_doc(url)
    Nokogiri::HTML(URI.open(url), nil, 'utf-8')
  end

  def get_list(doc, selector)
    doc.xpath(selector)
  end

  def get_element(doc, selector)
    doc.at_xpath(selector)
  end

  def clean_content(string)
    string.strip
  end

  def clean_date(date)
    Time.parse(date)
  end
end
