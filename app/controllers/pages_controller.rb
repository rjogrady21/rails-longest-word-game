require 'json'
require 'open-uri'

class PagesController < ApplicationController
  def game
    session[:characters] = @random_letters = generate_grid
    session[:time] = Time.now
  end

  def score
    @user_word = params[:user_word].upcase
    @user_word_length = @user_word.length
    @random_letters = params[:words_array]
    @word_checked = english_word?(@user_word)
    @start_time = session[:time]
    @end_time = Time.now
    @time_taken = @end_time - Time.parse(@start_time)
    @included = included?(@user_word, @random_letters)
    @result = score_and_message(@user_word, @random_letters, @time_taken)
  end

  def generate_grid
    new_array = Array.new(9) { ('A'..'Z').to_a.sample }
    new_array.join(" ")
  end

  def english_word?(user_word)
    url = "https://wagon-dictionary.herokuapp.com/#{user_word}"
    word_parsed = open(url).read
    JSON.parse(word_parsed)['found']
  end

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def score_and_message(attempt, grid, time)
    if included?(attempt, grid)
      if english_word?(attempt)
        return compute_score(attempt, time)
      else
        return 0
      end
    else
      return "not in the grid"
    end
  end

end





