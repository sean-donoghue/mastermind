module Mastermind
  class Game
    attr_reader :remaining_guesses, :result

    def initialize(code_breaker: HumanPlayer, code_maker: ComputerPlayer)
      @code_breaker = code_breaker.new(self)
      @code_maker = code_maker.new(self)
      @remaining_guesses = 12
      @result = {}
    end

    def play
      @code = @code_maker.pick_code
      show_intro
      game_loop
      end_game
    end

    private

    def show_intro
      puts "Mastermind\n\n"
      puts "The code-maker has created a code for you to crack."
      puts "There are 4 positions in the code."
      puts "Each position contains a digit between 1 and 6 inclusive.\n\n"
    end

    def game_loop
      until @result[:guess_matches_code?] || @remaining_guesses.zero?
        show_guess_feedback unless @result.empty?
        show_remaining_guesses
        @result = @code.guess @code_breaker.guess_code
        @remaining_guesses -= 1
      end
    end

    def show_guess_feedback
      puts "\nYour guess contains:"
      puts "#{@result[:correct]} correct digit(s)."
      puts "#{@result[:almost]} digit(s) in the incorrect position.\n\n"
    end

    def show_remaining_guesses
      puts "You have #{@remaining_guesses} guess(es) remaining."
    end

    def end_game
      if @result[:guess_matches_code?]
        puts "\nCode broken!"
        puts "The code-breaker wins!"
      else
        puts "\nGame over!"
        puts "The code-maker wins!"
      end
    end
  end

  class Code
    def initialize(code)
      Code.ensure_valid code
      @code = code
    end

    def self.valid?(code)
      return false unless code.is_a?(Array) && code.length == 4

      code.all? { |x| x.to_i.between?(1, 6) }
    end

    def self.ensure_valid(code)
      return if Code.valid? code

      raise ArgumentError, "Must be an array of 4 digits between 1-6 inclusive"
    end

    def self.random
      new(Array.new(4) { rand(1..6) })
    end

    def guess(guess)
      Code.ensure_valid guess

      {
        guess_matches_code?: guess == @code,
        correct: count_correct(guess),
        almost: count_almost_correct(guess)
      }
    end

    def count_correct(guess)
      guess.each_index.reduce(0) { |count, i| @code[i] == guess[i] ? count + 1 : count }
    end

    def count_almost_correct(guess)
      # Exclude digits that perfectly match or aren't in common
      filtered_guess = guess.select.with_index { |val, i| @code.include?(val) && @code[i] != val }
      filtered_code = @code.select.with_index { |val, i| guess.include?(val) && guess[i] != val }

      almost = 0

      filtered_code.each do |val|
        if filtered_guess.include? val
          almost += 1
          filtered_guess.delete_at filtered_guess.find_index val # Only count each digit once
        end
      end

      almost
    end
  end

  class Player
    def initialize(game)
      @game = game
    end

    def pick_code
      raise NotImplementedError
    end

    def guess_code
      raise NotImplementedError
    end
  end

  class HumanPlayer < Player
    def pick_code
      code = nil

      until Code.valid? code
        puts "Enter your four digit code! Each digit must be between 1-6 inclusive."
        print "Code: "
        code = gets.chomp.chars.map(&:to_i)

        puts "Invalid code! Try again." unless Code.valid? code
      end

      system("cls") || system("clear") # Hide code from the code-breaker
      Code.new code
    end

    def guess_code
      guess = nil

      until Code.valid? guess
        print "Guess: "
        guess = gets.chomp.chars.map(&:to_i)

        unless Code.valid? guess
          puts "Invalid guess! Try again."
          puts "This does not affect your #{@game.remaining_guesses} guess(es)."
        end
      end

      guess
    end
  end

  class ComputerPlayer < Player
    def initialize(game)
      super
      create_guesses
      @first_guess = true
    end

    def pick_code
      Code.random
    end

    def guess_code
      if @first_guess
        @first_guess = false
        @guess = [1, 1, 2, 2]
      else
        filter_guesses
        @guess = @guesses.first
      end

      puts "Computer guesses: #{@guess.join}"
      @guess
    end

    private

    def create_guesses
      @guesses = (1111..6666).map do |x|
        x.to_s.chars.map(&:to_i) if x.to_s.chars.none? { |c| %w[7 8 9 0].include? c } && x != 1122
      end.compact
    end

    def filter_guesses
      return if @guess.nil?

      # Filter remaining guesses based on Donald Knuth's five-guess algorithm
      # https://en.wikipedia.org/wiki/Mastermind_(board_game)#Worst_case:_Five-guess_algorithm
      @guesses = @guesses.select do |x|
        Code.new(x).guess(@guess) == @game.result
      end
    end
  end
end
