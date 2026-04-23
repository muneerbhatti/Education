class PostsController < ApplicationController
   def index
    @newsletters = Post.published
                             .page(params[:page])
                             .per(9)
  end

  def show
    @newsletter = Post.published.find_by!(slug: params[:slug])
  end
end
