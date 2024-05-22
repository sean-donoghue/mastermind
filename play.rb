require "./mastermind"

# Option 1: Defaults (Human code-breaker, Computer code-maker)
options = { code_breaker: Mastermind::HumanPlayer,
            code_maker: Mastermind::ComputerPlayer }

# Option 2: Human code-breaker, Human code-maker
# options = { code_breaker: Mastermind::HumanPlayer,
#             code_maker: Mastermind::HumanPlayer }

# Option 3: Computer code-breaker, Human code-maker
# options = { code_breaker: Mastermind::ComputerPlayer,
#             code_maker: Mastermind::HumanPlayer }

# Option 4: Computer code-breaker, Computer code-maker
# options = { code_breaker: Mastermind::ComputerPlayer,
#             code_maker: Mastermind::ComputerPlayer }

Mastermind::Game.new(**options).play
