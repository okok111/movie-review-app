class PostsController < ApplicationController
  before_action :authenticate_user! , except: [:show, :index]
    def index
        @posts = current_user.posts
    end

    def new
        @post = Post.new
        movie_id = params[:movie_id]
        url = "https://api.themoviedb.org/3/movie/#{movie_id}?api_key=#{ENV['TMDB_API']}&language=ja"
        response = Net::HTTP.get_response(URI.parse(url))
        if response.code == "200"
          @movie = JSON.parse(response.body)
          if @movie["overview"].blank?
            url_en = "https://api.themoviedb.org/3/movie/#{movie_id}?api_key=#{ENV['TMDB_API']}&language=en"
            response_en = Net::HTTP.get_response(URI.parse(url_en))
            if response_en.code == "200"
              movie_en = JSON.parse(response_en.body)
              @movie["overview"] = movie_en["overview"]
            end
          end
        else
          @movie = nil
        end
    end

    def create
        post = Post.new(post_params)
        post.user_id = current_user.id
        if post.save
            redirect_to :action => "index"
        else
            redirect_to :action => "new"
        end
    end

    def show
        @post = Post.find(params[:id])
    end

    def edit
        @post = Post.find(params[:id])
    end

    def update
        post = Post.find(params[:id])
        if post.update(post_params)
            redirect_to :action => "show", :id => post.id
        else
            redirect_to :action => "new"
        end
    end

    def destroy
        post = Post.find(params[:id])
        post.destroy
        redirect_to action: :index
    end

    private
    def post_params
        params.require(:post).permit(:title, :comment ,:image ,:overview)
    end
end
