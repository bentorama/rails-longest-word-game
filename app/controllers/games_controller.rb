require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    # @letters = []
    # alphabet = [*'A'..'Z']
    # 10.times { @letters << alphabet[rand(0..25)] }
    @letters = ('A'..'Z').to_a.sample(10)
    @start = Time.now
  end

  def score
    @word = params[:word]
    @letters = params[:letters]
    @start = Time.parse(params[:start])
    @end = Time.now
    @time_taken = @end - @start
    @english_word = english_word?
    @valid_word = valid_word?
    if @english_word && @valid_word
      @score = @word.length + (10 / @time_taken).round
    else
      @score = 0
    end

    @message = message(@english_word, @valid_word)

    if session[:score]
      session[:score] += @score
    else
      session[:score] = @score
    end
  end

  def reset
    session[:score] = 0
    redirect_to new_path
  end

  private

  def english_word?
    url = "https://wagon-dictionary.herokuapp.com/#{@word}"
    response = JSON.parse(open(url).read)
    response['found']
  end

  def valid_word?
    word_chars = @word.upcase.chars
    letter_chars = @letters.chars
    word_chars.all? do |char|
      word_chars.count(char) <= letter_chars.count(char)
    end
  end

  def message(english_word, valid_word)
    if english_word && valid_word
      'Great Job!!'
    elsif english_word
      'Sorry, this isn\'t a valid word'
    elsif valid_word
      'Sorry, this isn\'t an enlish word'
    else
      'Sorry. Try again'
    end
  end
end
