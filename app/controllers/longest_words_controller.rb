require 'open-uri'
require 'json'

class LongestWordsController < ApplicationController
  URL = "https://wagon-dictionary.herokuapp.com/"

  def game
    grid = generate_grid(9)
    @grid = grid.join
    @start_time = Time.now.to_i
  end

  def score
    @answer = params[:query]
    @end_time = Time.now
    start_time = params[:start_time].to_i
    @start_time = Time.at(start_time)
    @grid = params[:grid].split(//)
    @score_hash = run_game(@answer, @grid, @start_time, @end_time)
  end

  private

  def random_letter
    ('A'..'Z').to_a.sample
  end

  def generate_grid(grid_size)
    random_letter_tab = []
    grid_size.times { random_letter_tab << random_letter }
    random_letter_tab
  end

  def check_cheat(attempt, grid)
    attempt.upcase.chars.each do |x|
      return false if attempt.upcase.chars.count(x) > grid.count(x)
    end
    true
  end

  def check_valid_word(attempt)
    JSON.parse(open("#{URL}#{attempt}").read)["found"]
  end

  def my_score(time, word_length)
    word_length + (time * 1)
  end

  def run_game(attempt, grid, start_time, end_time)
    result_hash = { time: end_time - start_time, score: 0 }
    if !check_cheat(attempt, grid)
      result_hash[:message] = "not in the grid"
    elsif !check_valid_word(attempt)
      result_hash[:message] = "not an english word"
    else
      result_hash[:message] = "well done"
      result_hash[:score] = my_score(result_hash[:time], attempt.length)
    end
    result_hash
  end
end
