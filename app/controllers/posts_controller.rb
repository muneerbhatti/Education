class PostsController < ApplicationController
   def index
    @posts = Post.published
  end

  def show
    @post = Post.find_by!(slug: params[:slug])
  end
end
