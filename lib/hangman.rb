
# set up a sub-class in game class so that the contining the game
# will reset the stats by creating a new game object, instead of
# resetting the stats...ie: class Hangman and class Game?

# using (@wrong_guesses_left - 1) a lot for conditions.  Should be able to
# simplify how many times this is used in this way.  Perhaps another control
# variable?

# instead ofusing @wrong_guesses_left < 1 to check losing condition, make a
# "lost" variable

#  round_winner? and show_round_status methods seem really clunky in how they
# handle conditions for winning.  SHould be simpler way to manage this.

# have a variable: player_word_array that's set to same size as @word_array,
# but filled with "_" that get's filled in? and then can compare to @word_array
# to check win?  not sure if this is cleaner, but maybe more clear

# anything else?  any flow control that can be simplified (if/then, etc...)



class Player
  attr_reader :rounds_won, :rounds_lost

  def initialize(name)
    @name = name
    @rounds_won = 0
    @rounds_lost = 0
  end

  def increment_rounds_won
    @rounds_won += 1
  end

  def increment_rounds_lost
    @rounds_lost += 1
  end

  def reset_player_score
    @rounds_won = 0
    @rounds_lost = 0
  end

  def to_s
    "#{@name}"
  end

end # end class Player


class Hangman

  def initialize(player_name)
    @player = Player.new(player_name)
    @wrong_guesses_left = 6
    @word_array = []
    @word_positions_solved = []
    @letters_guessed = []
    @word_list = []
  end

  def play_game
    show_instructions
    keep_playing = true
    while keep_playing
      play_round
      keep_playing = play_again?
    end
    show_game_over
  end

  def play_round
    set_word
    round_over = false
    until round_over
      show_round_status
      letter = guess_letter
      update_round(letter)
      round_over = true if (round_winner? || @wrong_guesses_left < 1)
    end
    update_score
    show_round_status
    reset_round_stats
  end

  def set_word
    # default word in case file does not exist
    word = "WordListFileDoesNotExist"
    # word_list has only one word per line
    if File.exist? "../word_list.txt"
      File.open("../word_list.txt").each do |line|
        line_cleaned = line.chomp.strip
        if (line_cleaned.length >= 5 && line_cleaned.length <= 12)
          @word_list.push(line_cleaned)
        end
      end
      word = @word_list.sample
    end
    @word_array = word.upcase.split("")
    puts "set_word: The word is:  " + @word_array.join
  end

  # Returns letter chosen by user as guess.  Forces to capital lettes.
  # Returns nil string ("") if all letters have already been guessed.
  def guess_letter
    guess = ""
    if @letters_guessed.size > 0
      puts "\nSo far, you have already guessed the following letters:\n"
      show_letters_guessed
    end
    if @letters_guessed.size < 26
      begin
        puts "\nPlease select a letter to guess:"
        guess = gets.chomp.upcase
        unless guess =~ /^[A-Z]$/
          raise ArgumentError.new("Selection was not of the correct format.")
        end
        if @letters_guessed.include?(guess)
          raise ArgumentError.new("Selected letter has already been guessed.")
        end
      rescue ArgumentError=>e
        puts "Error: #{e.message}"
        retry
      end
    end
    return guess
  end

  def update_round(guess)
    if @word_array.include?(guess)
      @word_array.each_with_index do |letter, index|
        @word_positions_solved.push(index) if guess == letter
      end
    else
      @wrong_guesses_left -= 1
    end
    @letters_guessed.push(guess)
  end

  def update_score
    if @wrong_guesses_left < 1
      @player.increment_rounds_lost
    else
      @player.increment_rounds_won
    end
  end

  def round_winner?
    has_winner = false
    word_positions = []
    word_positions = (0..(@word_array.size-1)).to_a if (@word_array.size > 0)
    if word_positions.all? { |position| @word_positions_solved.include?(position) }
      has_winner = true
    end
    return has_winner
  end

  def show_round_status
    puts "================================================="
    clue_word_array = @word_array.clone
    @word_array.each_with_index do |letter, index|
      clue_word_array[index] = "_" unless @word_positions_solved.include?(index)
    end
    if round_winner?
      puts "\nYou Won! Congrats Dude :)"
      puts "You solved the word:  " + clue_word_array.join
      show_score
    elsif @wrong_guesses_left < 1
      puts "You Lost! Bummer Dude :("
      puts "The word was:  " + @word_array.join
      show_score
    else
      puts "\nHere's your clue so far:\n"
      puts clue_word_array.join(" ")
      error_singlular_plural = ( @wrong_guesses_left == 1 ) ? "error" : "errors"
      puts "\nYou have #{@wrong_guesses_left} more #{error_singlular_plural} allowed."
    end
    puts "\n-------------------------------------------------"
  end

  def play_again?
    valid_answer = %w{Y N YES NO}
    begin
      puts "Would you like to play again?  (Y or N)"
      choice = gets.chomp.upcase
      unless valid_answer.include?(choice)
        raise ArgumentError.new("Selection was not of the correct format.")
      end
    rescue ArgumentError=>e
      puts "Error: #{e.message}"
      retry
    end
    play_again = (choice[0] == "Y") ? true : false
  end

  def show_letters_guessed
    letters_formatted = @letters_guessed.join(", ")
    letters_formatted = "(#{letters_formatted})"
    puts letters_formatted
  end

  def show_score
    puts "\nYour current score is:"
    puts "\n#{@player.rounds_won} Rounds Won"
    puts "#{@player.rounds_lost} Rounds Lost"
  end

  def show_instructions
    puts "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    puts "\nThis is a classic game of Hangman...but without the cute pictures"
    puts "\nYou will be shown how many letters are in the mystery word, and"
    puts "then asked to guess the missing letters. Your are allowed a total of"
    puts "#{@wrong_guesses_left} 'misses' before the game will be lost."
    puts "\nAfter each round, there is an option continue playing more rounds,"
    puts "and the total number of rounds won and lost will be shown."
    puts "\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  end

  def show_game_over
    puts "-------------------------------------------------"
    puts "\nThanks for playing.  Bye-Bye!"
    puts "\n-------------------------------------------------"
  end

  def reset_round_stats
    @wrong_guesses_left = 6
    @word_array = []
    @word_positions_solved = []
    @letters_guessed = []
    @word_list = []
  end

end # end class Hangman

game = Hangman.new("Jason")
game.play_game
