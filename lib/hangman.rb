require "json"
require "./basic_serializable"

# Game shell with game menu
class Hangman

  def initialize
    @player = Player.new("Player")
    self.start_menu
  end

  protected

  # main start menu loop, to play/load game rounds
  def start_menu
    show_instructions
    @player.name = select_player_name
    game_over = false
    until game_over
      puts "================================================="
      puts "<><>------------    MAIN MENU    ------------<><>"
      puts "================================================="
      game = HangmanGame.new(@player)
      choice = select_game_type
      case choice
      when "N"
        puts "\nStarting a New Game...\n "
        puts "================================================="
        play_game(game)
      when "L"
        filename = "../saved_games/hangman_save.json"
        if File.exist?(filename)
          game.load_game(filename)
        else
          puts "\nSorry, no saved games available.  Starting a New Game...\n "
        end
        play_game(game)
      when "C"
        @player = Player.new(select_player_name)
      when "Q"
        puts "\nExiting the game...\n "
        game_over = true
      else
        puts "\nSomehow, an incorrect selection was processed, please try again...\n "
      end
    end
    show_game_over
  end

  private

  # main game loop
  # Parameter:  HangmanGame object
  def play_game(game)
    keep_playing = true
    while keep_playing
      game.play_round
      keep_playing = game.play_again?
    end
  end

  # Prompts player for start menu choice: New Game, Load Game, Change Player, or Quit
  # Return: player's choice (String)
  def select_game_type
    begin
      puts "\n#{@player}, would you like to play a new game, "
      puts "load and continue a previous game, "
      puts "change current player, or quit?"
      puts "(Enter 'N', 'L', 'C', or 'Q')"
      choice = gets.chomp.strip.upcase
      valid_answer = %w[N  L  C Q]
      unless valid_answer.include?(choice)
        raise ArgumentError.new("Selection was not of the correct format.")
      end
    rescue ArgumentError=>e
      puts "Error: #{e.message}"
      retry
    end
    return choice
  end

  # Prompts player for his/her name
  # Return: Player's Name (String)
  def select_player_name
    puts "\nWho's playing today? (please enter your name)"
    player_name = gets.chomp.strip
    puts "\nNice to meet you, #{player_name}.\n "
    return player_name
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
    puts "\nFrom the main start menu, you have four options: start a new game,"
    puts "load a saved game, change the current player, or quit the game."
    puts "\nOnce a game has begun, you'll have the option to continue playing"
    puts "more rounds after each completed round, and the current tallied "
    puts "score of rounds won/lost will be shown."
    puts "\nYou can also immediately exit from a round of play at any guess"
    puts "prompt, by typing in either 'save' (to save the game and exit the"
    puts "current round), or 'exit' (to exit the current round without saving)."
    puts "\nOnly one game can be saved at any given time.  Choosing to save"
    puts "another game will over-write any existing saved game."
    puts "\nPlease be forewarned...the word list used here encompasses a very"
    puts "wide vocabulary, may borrow from some other languages, and even"
    puts "includes names of countries...(eg: 'Cyprus' and 'Cymru', a native"
    puts "name for the country of Wales). it's a pretty tough list :)"
    puts "\n==================================================================="
  end

  def show_game_over
    puts "================================================="
    puts "================================================="
    puts "\nThanks for playing.  See you next time!"
    puts "\n================================================="
    puts "================================================="
  end

end #end Hangman class

# Player for Hangman
class Player

  include BasicSerializable

  attr_accessor :name
  attr_reader :rounds_won, :rounds_lost

  def initialize(name)
    @name = name
    @rounds_won = 0
    @rounds_lost = 0
  end

  def to_s
    "#{@name}"
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

end # end class Player


# Tracks state of one game of hangman, which can include one or multiple rounds
class HangmanGame

  include BasicSerializable

  def initialize(player)
    @player = player
    @word_list = set_word_list
    @word_array = []            # mystery word the player is guessing
    @word_array_player = []     # shows progress of correct guesses
    @letters_guessed = []       # All letters guessed already by player
    @errors_left = 6
    @round_over = false
    @round_won = false
    @continuing_saved_game = false
    # @continuing_saved_game:  Keeps game from resetting the round statistics
    # and word arrays when using a saved game, and from displying "Match/Miss"
    # in show_round_status, during 1st round of a continued saved game.
    # Set true in load_game, and resets to false in show_round_status
  end

  # Tracks one round of Hangman
  def play_round
    unless @continuing_saved_game == true
      reset_round_stats
      set_word_arrays
    end
    show_round_status   # @continuing_saved_game reset to false here
    until @round_over
      guess = guess_letter
      break if guess == "SAVE" || guess == "EXIT"
      update_round(guess)
      check_round_over?
      update_score if @round_over == true
      show_round_status
    end
  end

  # Return: True/False (Boolean)
  def play_again?
    valid_answer = %w[Y N]
    begin
      puts "\nWould you like to play another round?  (Y or N)"
      puts "('N' will return you to the start menu)"
      choice = gets.chomp.strip.upcase
      unless valid_answer.include?(choice)
        raise ArgumentError.new("Selection was not of the correct format.")
      end
    rescue ArgumentError=>e
      puts "Error: #{e.message}"
      retry
    end
    if choice == "Y"
      puts "\nBeginning a New Round...\n "
      puts "================================================="
    else
      puts "\nReturning to Main Menu...\n "
    end
    return (choice == "Y") ? true : false
  end

  def load_game(filename)
    puts "================================================="
    puts "\nLoading game..."
    all_lines = File.open(filename, "r").readlines
    all_lines.each { |line| line.chomp! }
    obj_string = all_lines.join
    self.unserialize(obj_string)
    @continuing_saved_game = true # gets reset to false in show_round_status
    puts "Saved Game Loaded."
    puts "\n================================================="
  end

  protected

  # to serialize data for saved games
  def serialize
    obj = {}
    obj[:players] = [@player.serialize]
    obj[:word_array] = @word_array
    obj[:word_array_player] = @word_array_player
    obj[:letters_guessed] = @letters_guessed
    obj[:errors_left] = @errors_left
    obj[:round_over] = @round_over
    obj[:round_won] = @round_won
    obj[:continuing_saved_game] = @continuing_saved_game
    @@serializer.dump(obj)
  end

  # unserialize data from saved games
  def unserialize(string)
    obj = @@serializer.parse(string, {:symbolize_names => true})
    # Note - seems like a hack, but only way I could get 1 player to un-json
    players = []
    obj[:players].each do |player_string|
      player = Player.new("")
      player.unserialize(player_string)
      players << player
    end
    @player = players[0]
    @word_array = obj[:word_array]
    @word_array_player = obj[:word_array_player]
    @letters_guessed = obj[:letters_guessed]
    @errors_left = obj[:errors_left]
    @round_over = obj[:round_over]
    @round_won = obj[:round_won]
    @continuing_saved_game = obj[:continuing_saved_game]
  end

  private

  # Fixed to a single game save file
  def save_game
    puts "================================================="
    puts "\nSaving game..."
    filename = "../saved_games/hangman_save.json"
    File.open(filename, "w") { |file| file.puts self.serialize }
    puts "Game Saved."
    puts "\n================================================="
  end

  # Create the list of words to draw from. Fixed for a single external file.
  # Only selects words between min_length and max_length letters long (inclusive).
  # Return: List of words (Array)
  def set_word_list
    word_list = []
    min_length = 5
    max_length = 12
    # Fixed external word_list file has only one word per line
    if File.exist? "../word_list.txt"
      File.open("../word_list.txt").each do |line|
        line_clean = line.chomp
        if (line_clean.length >= min_length && line_clean.length <= max_length)
          word_list.push(line_clean)
        end
      end
    else
      word_list.push("FileWordListTextDoesNotExist")
    end
    return word_list
  end

  def set_word_arrays
    @word_array = @word_list.sample.upcase.split("")
    @word_array_player = @word_array.map { |letter| letter = "_" }
  end

  # Returns letter or request chosen by user as guess.  Forces to capital letters.
  # Return: The guessed letter or command (String)
  def guess_letter
    guess = ""
    if @letters_guessed.size > 0
      puts "\nSo far, you have already guessed the following letters:"
      puts "(" + @letters_guessed.join(", ") + ")"
    end
    begin
      puts "\n\nPlease enter a letter for your guess: "
      puts "(or type the entire keyword: 'SAVE' or 'EXIT')"
      guess = gets.chomp.strip.upcase
      if guess == "SAVE"
        save_game
      elsif guess == "EXIT"
        puts "\nExiting the current round..."
        puts "\n================================================="
      else
        error_msg1 = "Selected letter was not of the correct format."
        raise ArgumentError.new(error_msg1) unless guess =~ /^[A-Z]$/
        error_msg2 = "Selected letter has already been guessed."
        raise ArgumentError.new(error_msg2) if @letters_guessed.include?(guess)
      end
    rescue ArgumentError=>e
      puts "Error: #{e.message}"
      retry
    end
    return guess
  end

  # updates letters solved, wrong guesses left, and letters guessed so far
  def update_round(guess)
    if @word_array.include?(guess)
      @word_array.each_with_index do |letter, index|
        @word_array_player[index] = letter if guess == letter
      end
    else
      @errors_left -= 1
    end
    @letters_guessed.push(guess)
  end

  # Return: True/False (Boolean)
  def check_round_over?
    word_match = @word_array.eql?(@word_array_player) ? true : false
    if word_match
      @round_won = true
      @round_over = true
    elsif @errors_left < 1
      @round_over = true
    end
  end

  # Shows result of players guess, and if round was won or lost.
  def show_round_status
    puts "================================================="
    # Do not display guess result before first guess, or on win/loss screen
    unless @letters_guessed.empty? || @continuing_saved_game == true
      puts (@word_array.include?(@letters_guessed.last) ? "\nMATCH!" : "\nMISS!")
    end
    @continuing_saved_game = false # Set to true during load_game.
    if @round_won
      puts "\nYou Won! Way to Go!\n "
      puts %Q(You solved the word:  "#{@word_array_player.join}")
      show_score
    elsif @round_over
      puts "\nYou Lost! Better luck next time...\n "
      puts %Q(The word was:  "#{@word_array.join}")
      show_score
    else
      puts "\n#{@player}, here's your clue so far:\n "
      puts @word_array_player.join(" ")
      puts "\nNumber of incorrect guesses left: #{@errors_left}"
    end
  end

  # Called only after a round is known to be won or lost
  def update_score
    if @round_won
      @player.increment_rounds_won
    else
      @player.increment_rounds_lost
    end
  end

  def show_score
    puts "\n\n#{@player}, Your current score is:"
    puts "\n#{@player.rounds_won} Rounds Won"
    puts "#{@player.rounds_lost} Rounds Lost"
  end

  def reset_round_stats
    @word_array = []
    @word_array_player = []
    @letters_guessed = []
    @errors_left = 6
    @round_over = false
    @round_won = false
    @continuing_saved_game = false
  end

end # end class HangmanGame

g = Hangman.new()
