# mastermind

This repository contains a solution to [The Odin Project's Mastermind project](https://www.theodinproject.com/lessons/ruby-mastermind).

The game can be played with the `play.rb` script via `ruby play.rb`, and play options
customised therein.

## Features

- Support for any combination of Human and Computer players in the code-maker and
  code-breaker roles.
- An intelligent computer player class based on
  [Donald Knuth's five-guess algorithm](<https://en.wikipedia.org/wiki/Mastermind_(board_game)#Worst_case:_Five-guess_algorithm>).
- Support for custom player classes, as long as they implement the `#pick_code` and
  `#guess_code` instance methods.
