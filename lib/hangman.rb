
# "MISS" and "MATCH" show up on the first round.
#
# after entering last incorrect guess... word_match = false in method
# round_over?  (when entering final correct to solve, it shows true).
# is this right?
#
# I think everything else is good. test with word_list set-word method, and
# then save, before moving onto save-game
#
#
#
#
#
#
#
#
#
#



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
    @errors_left = 6
    @word_array = []
    @word_array_player = []
    @letters_guessed = []
    @word_list = []
    @round_over = false
    @round_won = false

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
    set_word_arrays
    until @round_over
      show_round_status
      letter = guess_letter
      update_round(letter)
      check_round_over?
    end
    update_score
    show_round_status
    reset_round_stats
  end

  def set_word_arraysz
    word = "as"
    @word_array = word.upcase.split("")
    puts "set_word: The word is:  " + @word_array.join
    puts "@word_array is:"
    p @word_array
    @word_array_player = @word_array.map { |letter| letter = "_" }
    puts "@word_array_player is:"
    p @word_array_player
  end

  def set_word_arrays
    # default word in case file does not exist
    word = "Word_List_File_Does_Not_Exist"
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
    # puts "set_word: The word is:  " + @word_array.join
    @word_array_player = @word_array.map { |letter| letter = "_" }
  end

  # Returns letter chosen by user as guess.  Forces to capital lettes.
  # Returns nil string ("") if all letters have already been guessed.
  def guess_letter
    guess = ""
    if @letters_guessed.size > 0
      puts "\nSo far, you have already guessed the following letters:"
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

  # updates letters solved, wrong guesses left, and letters guessed so far
  def update_round(guess)
    if @word_array.include?(guess)
      @word_array.each_with_index do |letter, index|
        @word_array_player[index] = letter if letter == guess
      end
    else
      @errors_left -= 1
    end
    @letters_guessed.push(guess)
  end

  # Called only after a round is known to be won or lost
  def update_score
    if @round_won
      @player.increment_rounds_won
    else
      @player.increment_rounds_lost
    end
  end

  def check_round_over?
    word_match = @word_array.eql?(@word_array_player) ? true : false
    if word_match
      @round_won = true
      @round_over = true
    elsif @errors_left < 1
      @round_over = true
    end
  end

  def show_round_status
    # Do not display guess result before first guess, or on win/loss screen
    unless @letters_guessed.empty?
      puts "================================================="
      puts (@word_array.include?(@letters_guessed.last) ? "\nMATCH!" : "\nMISS!")
    end
    if @round_won
      puts "\nYou Won! Congratulations!"
      puts "You solved the word:  \"#{@word_array_player.join}\""
      show_score
    elsif @round_over
      puts "\nYou Lost! Better luck next time..."
      puts "The word was:  \"#{@word_array.join}\""
      show_score
    else
      puts "\nHere's your clue so far:"
      puts ""
      puts @word_array_player.join(" ")
      puts "\nNumber of incorrect guesses left: #{@errors_left}"
    end
  end

  def play_again?
    valid_answer = %w{Y N YES NO}
    begin
      puts "\nWould you like to play again?  (Y or N)"
      choice = gets.chomp.upcase
      unless valid_answer.include?(choice)
        raise ArgumentError.new("Selection was not of the correct format.")
      end
    rescue ArgumentError=>e
      puts "Error: #{e.message}"
      retry
    end
    puts "================================================="
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
    puts "==================================================================="
    puts "\nThis is a classic game of Hangman...but without the cute stick-"
    puts "figure pictures hanging from a tree :)"
    puts "\nYou will be shown how many letters are in the mystery word, and"
    puts "then asked to guess the missing letters. Your are allowed a total"
    puts "of #{@errors_left} 'misses'.  Guess the word before making so many losses, and"
    puts "you win...but make as many misses before guessing the word, and"
    puts "you lose."
    puts "\nAfter each round, you'll have the option to continue playing more"
    puts "rounds, and see the current tallied score of rounds won/lost."
    puts "\n==================================================================="
  end

  def show_game_over
    puts "================================================="
    puts "\nThanks for playing.  See you next time!"
    puts "\n================================================="
  end

  def reset_round_stats
    @errors_left = 6
    @word_array = []
    @word_array_player = []
    @letters_guessed = []
    @word_list = []
    @round_over = false
    @round_won = false
  end

end # end class Hangman

game = Hangman.new("Jason")
game.play_game
