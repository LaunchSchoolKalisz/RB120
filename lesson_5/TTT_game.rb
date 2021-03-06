require 'pry'

module Displayable
  def display_welcome_message
    puts "Welcome to Tic Tac Toe!"
    puts ""
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe! Goodbye!"
  end

  def clear_screen_and_display_board
    system_clear
    display_board
  end

  def display_board
    hmk = human.marker.strip
    cmk = computer.marker.strip
    puts ""
    puts "You are #{hmk}. #{computer.name} is #{cmk}."
    board.draw
    puts ""
  end

  def display_result
    case board.winning_marker
    when human.marker
      puts "You won!"
    when computer.marker
      puts "#{computer.name} won!"
    else
      puts "It's a tie!"
    end
  end

  def cont_next_round
    loop do
      puts ""
      puts "Press any key to start the next round."
      answer = STDIN.gets
      break unless answer.nil?
    end
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ""
  end

  def display_instructions
    puts "The first player to #{TTTGame::NUMBER_OF_WINS} wins, wins the game!"
  end

  def display_match_winner(scores)
    puts ""
    if scores[:human] > scores[:computer]
      puts "Congrats! You won the match!"
    else
      puts "Sorry, #{computer.name} won the match. Better luck next time!"
    end
    puts ""
  end

  def joinor(nums, punctuation = ", ", conjunction = "or")
    case nums.count
    when 1
      nums.join(punctuation.to_s)
    when 2
      "#{nums[0]} #{conjunction} #{nums[1]}"
    else
      last_num = nums.pop
      nums.join(punctuation.to_s) + "#{punctuation}#{conjunction} #{last_num}"
    end
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def draw
    puts "       |       |"
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts "       |       |"
    puts "-------+-------+-------"
    puts "       |       |"
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts "       |       |"
    puts "-------+-------+-------"
    puts "       |       |"
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts "       |       |"
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
end

module ValidateUserInput
  def valid_integer?(number)
    number % 1 == 0
  end

  def validate_player
    player = nil
    loop do
      player = gets.chomp.capitalize
      break if player == human.name || player == computer.name
      puts "Please enter a valid response: #{human.name} or #{computer.name}"
    end
    player
  end

  def valid_square
    square = nil
    loop do
      square = gets.chomp.to_f
      break if board.unmarked_keys.include?(square) && valid_integer?(square)
      puts "Sorry, that's not a valid choice. Try again!"
    end
    board[square.to_i] = human.marker
  end

  def valid_y_or_n
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if ['y', 'n'].include? answer
      puts "Sorry, your response must be y or n"
    end
    answer == 'y'
  end

  def valid_name
    answer = nil
    loop do
      puts "What is your name?"
      answer = gets.chomp.strip.capitalize
      break unless answer.empty? || Computer::COMPUTER_NAMES.include?(answer)
      puts "Sorry that's not a valid choice."
    end
    answer
  end

  def valid_marker
    answer = nil
    loop do
      puts "What would you like the marker for #{name} to be?"
      answer = gets.chomp.strip.capitalize
      break if answer.chars.count == 1
      puts "Sorry, invalid choice. Markers must be 1 character, please."
    end
    answer = " #{answer} "
  end
end

class TTTGame
  include Displayable
  include ValidateUserInput

  NUMBER_OF_WINS = 2

  attr_reader :board, :human, :computer
  attr_accessor :player_marker, :comp_marker, :current_player

  def initialize
    @human = Human.new
    @computer = Computer.new
    @player_marker = player_marker
    @comp_marker = comp_marker
    @board = Board.new
    @current_player = current_player
  end

  def setup
    @human.set_name
    @computer.set_name
    @player_marker = @human.set_marker
    loop do
      @comp_marker = @computer.set_marker
      break unless @player_marker == comp_marker
      puts "Please enter a marker which is different than the player's!"
    end
    @current_player = human.name
    set_board_markers
  end

  def play
    system_clear
    display_welcome_message
    setup
    main_game
    display_goodbye_message
  end

  private

  def main_game
    loop do
      match_sequence(scores)
      break unless play_again?
      reset
      display_play_again_message
    end
  end

  def match_sequence(scores)
    chooser = who_chooses_who_goes_first
    choose_player_one(chooser)
    loop do
      match_display_and_clear(scores)
      move(scores)
      break if scores.values.include?(NUMBER_OF_WINS)
      match_end(chooser)
    end
    display_scoreboard(scores)
    display_match_winner(scores)
  end

  def move(scores)
    player_move
    update_scoreboard(scores)
    clear_screen_and_display_board
  end

  def player_move
    loop do
      current_player_moves
      break if board.someone_won? || board.full?
      clear_screen_and_display_board
    end
  end

  def scores
    { human: 0, computer: 0 }
  end

  def human_moves
    puts "Choose an empty square (#{joinor(board.unmarked_keys)}): "
    valid_square
  end

  def computer_moves
    square = comp_move(comp_marker)
    if !square
      square = comp_move(player_marker)
    end
    if !square
      square = comp_choose_square
    end
    board[square] = computer.marker
  end

  def comp_move(marker)
    square = nil
    Board::WINNING_LINES.each do |line|
      square = board.find_at_risk_square(line, marker)
      break if square
    end
    square
  end

  def comp_choose_square
    if board.unmarked_keys.include?(5)
      5
    else
      board.unmarked_keys.sample
    end
  end

  def choose_player_one(chooser)
    return @current_player = human_chooses_player_one if chooser == human.name
    @current_player = [human.name, computer.name].sample
  end

  def human_chooses_player_one
    puts "Who should go first: #{human.name} or #{computer.name}?"
    validate_player.capitalize
  end

  def current_player_moves
    if human_turn?
      human_moves
      @current_player = computer.name unless board.someone_won? || board.full?
    else
      computer_moves
      @current_player = human.name unless board.someone_won? || board.full?
    end
  end

  def human_turn?
    return true if @current_player == human.name
    false
  end

  def play_again?
    valid_y_or_n
  end

  def who_chooses_who_goes_first
    puts "Who should choose who goes first: #{human.name} or #{computer.name}?"
    validate_player.capitalize
  end

  def match_end(chooser)
    display_result
    cont_next_round
    system_clear
    choose_player_one(chooser)
    reset
    display_scoreboard(scores)
  end

  def system_clear
    system 'clear'
  end

  def reset
    board.reset
    system_clear
  end

  def update_scoreboard(scores)
    case board.winning_marker
    when human.marker
      scores[:human] += 1
    when computer.marker
      scores[:computer] += 1
    end
    scores
  end

  def display_scoreboard(scores)
    puts ""
    puts "------SCOREBOARD------"
    puts "#{human.name} has #{scores[:human]} points."
    puts "#{computer.name} has #{scores[:computer]} points."
  end

  def match_display_and_clear(scores)
    system_clear
    display_instructions
    display_scoreboard(scores)
    display_board
  end

  def set_board_markers
    board.player_marker = @player_marker
    board.comp_marker = @comp_marker
  end
end

class Board
  include Displayable
  include ValidateUserInput

  attr_accessor :player_marker, :comp_marker

  WINNING_LINES =
    [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
    [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # columns
    [[1, 5, 9], [3, 5, 7]] # diags

  def initialize
    @squares = {}
    reset
  end

  def []=(key, marker)
    @squares[key].marker = marker
  end

  def []
    @squares[key]
  end

  def unmarked_keys
    human_marked_keys = @squares.keys.select do |key|
      @squares[key].marker == player_marker
    end
    computer_marked_keys = @squares.keys.select do |key|
      @squares[key].marker == comp_marker
    end
    @squares.keys - human_marked_keys - computer_marked_keys
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  # return winning marker or nil
  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if three_identical_markers?(squares)
        return squares.first.marker
      end
    end
    nil
  end

  def gather_markers(squares)
    squares.select(&:marked?).collect(&:marker)
  end

  def three_identical_markers?(squares)
    markers = gather_markers(squares)
    return false if markers.size != 3
    markers.min == markers.max
  end

  def find_at_risk_square(line, marker)
    sqrs = @squares.values_at(*line)
    markers = gather_markers(sqrs)
    if two_markers?(markers, marker)
      sq = square_to_mark(markers, marker)
      idx = markers.index(sq.join)
      return @squares.key(sqrs[idx])
    end
    nil
  end

  def square_to_mark(markers, marker)
    markers.select do |square|
      if markers.count(marker) == 2
        square != marker
      end
    end
  end

  def two_markers?(markers, marker)
    other_marker = other_marker(marker)
    if (markers.count(marker)) == 2 && (markers.include?(other_marker) == false)
      true
    else
      false
    end
  end

  def other_marker(marker)
    if marker == comp_marker
      player_marker
    else
      comp_marker
    end
  end

  def reset
    (1..9).each do |key|
      square = Square.new("[#{key}]")
      @squares[key] = square
      square.player_marker = player_marker
      square.comp_marker = comp_marker
    end
  end
end

class Square
  include Displayable
  attr_accessor :marker, :player_marker, :comp_marker

  def initialize(marker)
    @marker = marker
  end

  def to_s
    @marker
  end

  def human_marked?
    marker == player_marker
  end

  def computer_marked?
    marker == comp_marker
  end

  def marked?
    marker != (human_marked? && computer_marked?)
  end
end

class Player
  attr_accessor :name, :marker

  include ValidateUserInput
  include Displayable

  def set_marker
    @marker = valid_marker
  end
end

class Human < Player
  def set_name
    @name = valid_name
  end
end

class Computer < Player
  COMPUTER_NAMES = ["Odin", "Frigg", "Thor", "Loki"] +
                   ["Balder", "Hod", "Heimdall", "Tyr"]

  def set_name
    @name = COMPUTER_NAMES.sample
  end
end

game = TTTGame.new
game.play
