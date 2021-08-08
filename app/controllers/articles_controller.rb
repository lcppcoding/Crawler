class ArticlesController < ApplicationController
  include ArticlesHelper

  def index
    @articles = Article.all
    @articles = @articles.send(params[:source]) if params[:source].present?
    @articles = @articles.query(params[:query]) if params[:query].present?
  end

  def fetch_articles
    # TODO: Get source from params and call helper. Do this in the background: SLOW SLOW
    FetchNewsJob.perform_later update_articles('Cultura')
    FetchNewsJob.perform_later update_articles('Desenvolvimento Social')
  end
end
