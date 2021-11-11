=begin 
GAME DESCRIPTION

Tic tac toe is a 2 player game. The game is set up with a 9-square grid. Player 1 marks the board with an x. Player 2 counters
with their marker, an o. The players take turns, tryng to mark 3 consecutive squares on the grid with their markers (winner).

LS Description
Tic Tac Toe is a 2-player board game played on a 3x3 grid. Players take turns
marking a square. The first player to mark 3 squares in a row wins.

Nouns: board, player, grid, square, marker
Verbs: play, mark

Board
Square
Player
  - Mark
  - Play

SPIKE
=end

class TTTGame
  attr_reader :board

  def initialize
    @board = Board.new
  end

  def display_welcome_message
    puts "Welcome to Tic Tac Toe!"
    puts ""
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe! Goodbye!"
  end

  def display_board
    puts ""
    puts "     |     |"
    puts " #{board.get_square_at(1)}   |     |"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "     |     |"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "     |     |"
    puts "     |     |"
    puts ""
  end

  def play
    display_welcome_message
    loop do 
      display_board
      break
      first_player_moves
      break if someone_won? || board_full?

      second_player_moves
      break if someone_won? || board_full?
    end
    # display_result
    display_goodbye_message
  end
end

class Board
  INITIAL_MARKER = " "

  def initialize
    @squares = {}
    (1..9).each {|key| @squares[key] = Square.new(INITIAL_MARKER)}
  end

  def get_square_at(key)  
    @squares[key]         #will return a square object
  end
end

class Square
  def initialize(marker)
    @marker = marker
  end

  def to_s
    @marker
  end
end

class Player
  def initialize
    # Marker to keep track of player's symbol?
  end

  def mark
  end

  def play
  end
end

game = TTTGame.new
game.play