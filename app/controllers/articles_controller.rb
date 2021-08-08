class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def fetch_articles
    # TODO: Get source from params and call helper
  end
end
