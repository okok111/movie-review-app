class MoviesController < ApplicationController
  before_action :authenticate_user! , except: [:show, :search ,:recommend]
  def search
    if params[:looking_for]
      movie_title = params[:looking_for]
      movies = []
      (1..5).each do |page|
        url = "https://api.themoviedb.org/3/search/movie?api_key=#{ENV['TMDB_API']}&language=ja&query=" + URI.encode_www_form_component(movie_title) + "&page=#{page}"
        response = Net::HTTP.get_response(URI.parse(url))
        if response.code == "200"
          result = JSON.parse(response.body)
          movies.concat(result["results"])
        end
      end
    else
      movies = []
      (1..5).each do |page|
        url = "https://api.themoviedb.org/3/movie/popular?api_key=#{ENV['TMDB_API']}&language=ja&page=#{page}"
        response = Net::HTTP.get_response(URI.parse(url))
        if response.code == "200"
          result = JSON.parse(response.body)
          movies.concat(result["results"])
        end
      end
    end
    @movies = Kaminari.paginate_array(movies).page(params[:page]).per(16)
  end

  def show
    movie_id = params[:id]
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

  def recommend
    @question = params[:query]

    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
    response = client.chat(
      parameters: {
          model: "gpt-3.5-turbo",
          messages: [{ role: "user", content: "次の単語に該当する映画を５つ紹介してください。#{@question}" }],
      })

    @answer = response.dig("choices", 0, "message", "content")
  end
end
