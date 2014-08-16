class HomeController < ApplicationController
  def index
    @posts = Post.order(updated_at: :desc)
  end
end
