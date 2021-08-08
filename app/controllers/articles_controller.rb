class ArticlesController < ApplicationController
  include ArticlesHelper

  def index
    @articles = Article.all
    @articles = @articles.send(params[:source]) if params[:source].present?
    @articles = @articles.query(params[:query]) if params[:query].present?
  end

  def fetch_articles
    # TODO: Get source from params and call helper. Do this in the background: SLOW SLOW
    update_articles('Cultura')
    update_articles('Desenvolvimento Social')
  end
end
