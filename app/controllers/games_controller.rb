require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = (1..10).reduce([]) { |acc, _| acc << ('A'..'Z').to_a.sample }
  end

  def score
    word = params[:word]
    letters = params[:letters].gsub(/\s+/, "")
    answer = get_answer_api(word)

    in_grid = word.upcase.chars.all? do |x|
      x.match?(Regexp.new("[#{letters}]"))
      letters.sub!(x, '')
    end

    # score = in_grid && answer["found"] ? attempt.size / time : 0
    @message = get_answer(in_grid, answer, params[:letters])
  end

  private

  def get_answer_api(word)
    url = "https://wagon-dictionary.herokuapp.com/#{word}"
    answer_serialized = URI.open(url).read
    JSON.parse(answer_serialized)
  end

  def get_answer(in_grid, answer, letters)
    if in_grid && answer["found"]
      return "Congratulation! #{answer["word"].upcase} is a valid English word!"
    elsif !in_grid && answer["found"]
      return "Sorry but #{answer["word"].upcase} can't be build of #{letters}"
    else
      return "Sorry but #{answer["word"].upcase} does not seem to be a valid English word..."
    end
  end
end
