#lang forge/bsl 
open "connect4.frg"

-- test suite for wellformed
test suite for wellformed {

  -- RED can move into the following squares for ROWS when the board is a 5x5 board
  example firstRow_wellformed is {allBoardsWellformed} for {
    Board = `Board0
    Red = `Red0
    Yellow = `Yellow0
    Player = Red + Yellow
    `Board0.board = (0,0) -> Red + 
                    (0,1) -> Red + 
                    (0,2) -> Red + 
                    (0,3) -> Red + 
                    (0,4) -> Red + 
                    (0,5) -> Red 
  }

  -- RED cannot move into the following squares for ROWS when the board is a 5x5 board (constrained by forge to 8)
  example firstRow_not_wellformed is {not allBoardsWellformed} for {
    Board = `Board0
    Red = `Red0
    Yellow = `Yellow0
    Player = Red + Yellow
    `Board0.board = (0,6) -> Red +
                    (0,7) -> Red 
  }

  -- RED cannot move into negative squares for ROWS when the board is a 5x5 board (constrained by forge to 8)
  example neg_firstRow_not_wellformed is {not allBoardsWellformed} for {
    Board = `Board0
    Red = `Red0
    Yellow = `Yellow0
    Player = Red + Yellow
    `Board0.board = (0,-3) -> Red +
                    (0,-2) -> Red 
  }

  -- RED can move into the following squares for COLS when the board is a 5x5 board
  example firstCol_wellformed is {allBoardsWellformed} for {
    Board = `Board0
    Red = `Red0
    Yellow = `Yellow0
    Player = Red + Yellow
    `Board0.board = (0,0) -> Red + 
                    (1,0) -> Red + 
                    (2,0) -> Red + 
                    (3,0) -> Red + 
                    (4,0) -> Red + 
                    (5,0) -> Red 
  }

  -- RED cannot move into the following squares for COLS when the board is a 5x5 board (constrained by forge to 8)
  example firstCol_not_wellformed is {not allBoardsWellformed} for {
    Board = `Board0
    Red = `Red0
    Yellow = `Yellow0
    Player = Red + Yellow
    `Board0.board = (6,0) -> Red +
                    (7,0) -> Red 
  }

  -- RED cannot move into negative squares for COLS when the board is a 5x5 board (constrained by forge to 8)
  example neg_firstCol_not_wellformed is {not allBoardsWellformed} for {
    Board = `Board0
    Red = `Red0
    Yellow = `Yellow0
    Player = Red + Yellow
    `Board0.board = (-1,0) -> Red +
                    (-2,0) -> Red 
  }
  -- all boards are wellformed
  test expect { allWellformedBoard: {all b: Board | wellformed[b]} is sat }

  -- contradiction in wellformed
  test expect { contradictionInWellformedness: {some b: Board | wellformed[b] and not wellformed[b]} is unsat }

  -- there are no invalid moves on wellformed boards
  test expect { noInvalidMovesOnWellformedBoard: {all b: Board | wellformed[b] implies 
    (all row, col: Int | (row < MIN or row > MAXROW or col < MIN or col > MAXCOL) implies no b.board[row][col])} is theorem }
}

-- test suite for initial
test suite for initial {
  example validInitialBoard is {allBoardsInitial} for {
    Board = `Board0
    Red = `Red0
    Yellow = `Yellow0
    Player = Red + Yellow
    no `Board0.board 
  }

  example invalidInitialBoardOneMove is {not allBoardsInitial} for {
    Board = `Board0
    Red = `Red0
    Yellow = `Yellow0
    Player = Red + Yellow
    `Board0.board = (0,0) -> Red
  }

  -- all initial boards are empty
  test expect { allInitialBoardsAreEmpty: {all r, c : Int, b: Board | initial[b] implies no b.board[r][c]} is sat }

  -- there exists a board that is not initial
  test expect { existsNonInitialBoard: {some b: Board | not initial[b]} is sat }

  -- a board that is an intial board, does not have a "position" filled in
  test expect { notEmptyInitialBoard: { all b: Board | initial[b] and some b.board[0][0]} is unsat }
  
  -- an initial board means it is reds turn
  assert emptySingleBoard is sufficient for someRedTurn 
}

test suite for Redturn{

  -- all initial boards are red turn
  test expect { allInitialRedTurn: {all b: Board | initial[b] and Redturn[b]} is sat }

  -- there exists some board where it is not reds turn
  test expect { existsNonRedTurn: {some b: Board | not Redturn[b]} is sat }

  -- no initial boards where it is initial and not red turn
  test expect { initialBoardNotRedTurn: {all b: Board | initial[b] and not Redturn[b]} is unsat }

  -- contradiction in red turn
  test expect { contradictionInRedTurn: {some b: Board | Redturn[b] and not Redturn[b]} is unsat }

  -- some red turn is necessary that the board is empty
  assert someRedTurn is necessary for emptySingleBoard
}

test suite for Yellowturn{

  -- it is yellows turn
  example yellowTurn_valid is {YellowturnTest} for {
    Board = `Board0
    Red = `Red0
    Yellow = `Yellow0
    Player = Red + Yellow
    `Board0.board = (0,0) -> Red 
  }

  -- it is not yellows turn
  example yellowTurn_invalidEqual is {not YellowturnTest} for {
    Board = `Board0
    Red = `Red0
    Yellow = `Yellow0
    Player = Red + Yellow
    `Board0.board = (0,0) -> Red +
                    (1,0) -> Yellow 
  }

    -- all initial boards are not yellow turn
  test expect { notYellowInit: {all b: Board | initial[b] and not Yellowturn[b]} is sat }

  -- there exists some board where it is not yellows turn
  test expect { existsNonYellowTurn: {some b: Board | not Yellowturn[b]} is sat }

  -- contradiction in yellow turn
  test expect { contradictionInYellowTurn: {some b: Board | Yellowturn[b] and not Yellowturn[b]} is unsat }

}

test suite for winning {
  -- a player wins horizontally
  example horizontalWin is {winningTest} for {
    Board = `Board0
    Red = `Red0
    Yellow = `Yellow0
    Player = Red + Yellow
    `Board0.board = (2,0) -> Red +
                    (2,1) -> Red +
                    (2,2) -> Red +
                    (2,3) -> Red
  }
  
  -- a player wins vertically
  example verticalWin is {winningTest} for {
    Board = `Board0
    Red = `Red0
    Yellow = `Yellow0
    Player = Red + Yellow
    `Board0.board = (0,1) -> Yellow +
                    (1,1) -> Yellow +
                    (2,1) -> Yellow +
                    (3,1) -> Yellow
  }

  -- a player wins diagonally from top left to bottom right
  example diagonalWinTRBL is {winningTest} for {
    Board = `Board0
    Red = `Red0
    Yellow = `Yellow0
    Player = Red + Yellow
    `Board0.board = (0,0) -> Red +
                    (1,1) -> Red +
                    (2,2) -> Red +
                    (3,3) -> Red
  }

  -- a player wins diagonally from bottom left to top right
  example diagonalWinBRTL is {winningTest} for {
    Board = `Board0
    Red = `Red0
    Yellow = `Yellow0
    Player = Red + Yellow
    `Board0.board = (3,0) -> Yellow +
                    (2,1) -> Yellow +
                    (1,2) -> Yellow +
                    (0,3) -> Yellow
  }

  -- not enough pieces in a row to win
  example notWinning is {not winningTest} for {
    Board = `Board0
    Red = `Red0
    Yellow = `Yellow0
    Player = Red + Yellow
    `Board0.board = (0,0) -> Red +
                    (0,1) -> Red +
                    (0,2) -> Red
  }

  test expect {
    winningPreserved: { 
      allBoardsWellformed
      winningPreservedCounterexample } is unsat
  }

  -- there exists at least one board where red is winning
  test expect { existsRedWinning: {some b: Board | winning[b, Red]} is sat }

  -- there exists at least one board where yellow is winning
  test expect { existsYellowWinning: {some b: Board | winning[b, Yellow]} is sat }

  -- Expectation: No player wins in multiple ways on the same board
  test expect { noMultipleWins: {all b: Board, p: Player | game_trace and winning[b, Red] and winning[b, Yellow] } is unsat }

  -- check sufficient conditions for winning
  assert winningRowTest is sufficient for any_winner_exists 
  assert winningColTest is sufficient for any_winner_exists 
  assert winningDiagonalTest is sufficient for any_winner_exists 
}

 test suite for move{
  -- a valid move is always possible unless the game has been won or the board is full
  test expect { validMovePossible: {some pre, post: Board, row, col: Int, turn: Player | 
      (not winning[pre, Red] and not winning[pre, Yellow]) and move[pre, row, col, turn, post]} is sat }

  -- a move to be made if it's yellows player's turn
  test expect { moveOnYellowTurn: {all pre, post: Board, row, col: Int, turn: Player | 
      (not Redturn[pre]) implies move[pre, row, col, Yellow, post]} is sat }

  -- a move to be made if it's red player's turn
  test expect { moveOnRedTurn: {all pre, post: Board, row, col: Int, turn: Player | 
      (not Yellowturn[pre]) implies move[pre, row, col, Red, post]} is sat }

  -- a move shows that a square is occupied by the player who made the move
  test expect { validMoveResultsInOccupiedSquare: {all pre, post: Board, row, col: Int, turn: Player | 
      move[pre, row, col, turn, post] implies post.board[row][col] = turn} is sat }

  -- a move shows that no additional pieces are added except for the one in the move
  test expect { onlyOnePieceAddedPerMove: {all pre, post: Board, row, col: Int, turn: Player | 
      move[pre, row, col, turn, post] implies
      (add[#{r, c: Int | pre.board[r][c] = turn}, 1] = #{r, c: Int | post.board[r][c] = turn})} is sat} 

  -- a move shows that the target square is not occupied by the other player
  test expect { invalidMoveToOccupiedSquare: {all pre, post: Board, row, col: Int, turn: Player | 
    some pre.board[row][col] and move[pre, row, col, turn, post]} is unsat }

}

test suite for doNothing{
  -- a boeard does nothing if the game has been won
  test expect { winningBoardDoesNothing: {all pre, post: Board, p: Player | 
    winning[pre, p] implies doNothing[pre, post]} is sat }

  -- an unwon game does not do nothing
  test expect { nonWinningBoardDoesNotDoNothing: {all pre, post: Board | 
    (all p: Player | not winning[pre, p]) implies not doNothing[pre, post]} is sat }
  
  --  satisfy both winning and doNothing predicates and be different in the pre and post states
  test expect { winningAndDoingNothing: {all pre, post: Board, p: Player | 
    winning[pre, p] and doNothing[pre, post] and (pre != post)} is unsat }

}