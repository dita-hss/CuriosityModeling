#lang forge/bsl 

option run_sterling "connect4s.js"
abstract sig Player {} 
one sig Red, Yellow extends Player {} 

sig Board { 
    board: pfunc Int -> Int -> Player
}

one sig Game {
    first: one Board, 
    next: pfunc Board -> Board
}

-- constants for rows and columns
fun MIN: one Int { 0 }
//we can make board bigger but for now it is 6x6
fun MAXCOL: one Int { 5 }
fun MAXROW: one Int { 5 }

-- make sure that all boards are a certain size
pred wellformed[b: Board] {
    all row, col: Int | {
            (row < MIN or row > MAXROW or 
            col < MIN or col > MAXCOL) implies
                no b.board[row][col]
    } 
}

-- an intial board is one where no moves have been made
pred initial[b: Board] {
    all row, col: Int | no b.board[row][col]
}

-- it is Red's turn if the number of reds is equal to the number of Yellows
pred Redturn[b: Board] {
    #{row, col: Int | b.board[row][col] = Red} 
    = 
    #{row, col: Int | b.board[row][col] = Yellow} 
}

-- it is Yellow's turn if the number of reds is one more than the number of Yellows
pred Yellowturn[b: Board] {
    #{row, col: Int | b.board[row][col] = Red} 
    = 
    add[#{row, col: Int | b.board[row][col] = Yellow}, 1]
}

-- must be either Red or Yellow's turn
pred balanced[b: Board] {
    Redturn[b] or Yellowturn[b]
}

-- define what it means to win for a player on a board
pred winning[b: Board, p: Player] {
    -- 4 in a row
    (some r, c: Int | { 
        b.board[r][c] = p and
        b.board[r][add[c, 1]] = p and
        b.board[r][add[c, 2]] = p and
        b.board[r][add[c, 3]] = p
    })
    or
    -- 4 in a col 
    (some r, c: Int | { 
        b.board[r][c] = p and
        b.board[add[r, 1]][c] = p and
        b.board[add[r, 2]][c] = p and
        b.board[add[r, 3]][c] = p
    })
    or 
    -- 4 in a diagonal
    (some r, c: Int | { 
        b.board[r][c] = p and
        b.board[add[r, 1]][add[c, 1]] = p and
        b.board[add[r, 2]][add[c, 2]] = p and
        b.board[add[r, 3]][add[c, 3]] = p
    })
    or 
    -- 4 in a diagonal
    (some r, c: Int | { 
        b.board[r][c] = p and
        b.board[add[r, 1]][subtract[c, 1]] = p and
        b.board[add[r, 2]][subtract[c, 2]] = p and
        b.board[add[r, 3]][subtract[c, 3]] = p
    })
}

-- from a pre board, we can make a move to a post board
pred move[pre: Board, 
          row, col: Int, 
          turn: Player, 
          post: Board] {
    -- guard: 

    -- enforce valid move index
    row >= MIN
    row <= MAXROW
    col >= MIN
    col <= MAXCOL
    
    -- the square we move to is currently empty
    no pre.board[row][col]

    -- it is the correct players turn
    turn = Red implies Redturn[pre]
    turn = Yellow implies Yellowturn[pre]

    -- once a player wins the game, the game no longer progresses
    all p: Player | not winning[pre, p]


    -- ensures that pieces get stacked
    all int : Int | {
        (int >= MIN and int < row) implies some pre.board[int][col]
    }

    -- mark the location with the player 
    post.board[row][col] = turn 
    
    -- other squares stay the same  ("frame condition")
    all row2: Int, col2: Int | (row!=row2 or col!=col2) implies {
        post.board[row2][col2] = pre.board[row2][col2]
    }
}

-- in the event a player has won, do nothing for remaining boards
pred doNothing[pre, post: board] {
    -- guard: some player has won
    some p: Player | winning[pre, p]

    -- board stays the same
    all r, c: Int | {
        pre.board[r][c] = post.board[r][c]
    }
}

pred game_trace {
    initial[Game.first]
    all b: Board | { some Game.next[b] implies {
        (some row, col: Int, p: Player | 
            move[b, row, col, p, Game.next[b]])
        or
            doNothing[b, Game.next[b]]
    }}
}

pred winningDiagonally[b: Board, p: Player] {
    -- 4 in a diagonal from top-left to bottom-right
    (some r, c: Int | { 
        b.board[r][c] = p and
        b.board[add[r, 1]][add[c, 1]] = p and
        b.board[add[r, 2]][add[c, 2]] = p and
        b.board[add[r, 3]][add[c, 3]] = p
    })
    or 
    -- 4 in a diagonal from bottom-left to top-right
    (some r, c: Int | { 
        b.board[r][c] = p and
        b.board[add[r, 1]][subtract[c, 1]] = p and
        b.board[add[r, 2]][subtract[c, 2]] = p and
        b.board[add[r, 3]][subtract[c, 3]] = p
    })
}

// ensures that a winner exists for some board
pred any_winner_exists{
    some p : Player, b : Board | {
        winning[b, p] 
    }
}

pred winningDiagonallyExists {
    some p : Player, b : Board | {
        winningDiagonally[b, p] 
    }
}


-------------------------------------Curiosity Runs------------------------------------------------
-- 1. any player wins in 15 or less moves
run { 
    game_trace
    -- include if interested in games with a winner
    any_winner_exists
} for 15 Board for {next is linear}



-- 2. player wins diagonally in 15 or less moves
    -- specific player can be mentioned (red or yellow)
// run { 
//     game_trace
//     -- winningDiagonallyExists
//     all p : Player, b : Board | {
//         not winning[b, p] 
//     }

//     -- indicating a winner increases the amount of time to run due to redundant checks
//         -- yellow 
//         //some b : Board | winning[b, Yellow]
//         -- red
//         //some b : Board | winning[b, Red]
// } for 15 Board for {next is linear}



-- 3. player wins after every possible move is made (36 moves)
// run {
//     game_trace
//     #Board = 37
//     -- board without a next state is a winning board
//     all b: Board | not some Game.next[b] and (winning[b, Red] or winning[b, Yellow])
// } for 37 Board for {next is linear}



-- 4. no winner exists after every possible move is made (36 moves)
// run { 
//     game_trace
//     not any_winner_exists
// } for 37 Board for {next is linear}



-- 5. winning with no diagonals
// run {
//     game_trace
//     any_winner_exists
//     all b: Board | not winningDiagonally[b, Red] and not winningDiagonally[b, Yellow]
// } for 36 Board for {next is linear}



// -- 6. playing on non wellformed games 
// run {
//     game_trace
//     some b: Board | not wellformed[b]
// } for 37 Board for {next is linear}


-------------------------------------Test Predicates------------------------------------------------

-- all boards are wellformed
pred allBoardsWellformed { all b: Board | wellformed[b] }

-- all boards are initial
pred allBoardsInitial { all b: Board | initial[b] }

pred emptySingleBoard {
  one b: Board | true
  all b: Board, r,c: Int | no b.board[r][c]
}

-- if the game is inital, then it is Red's turn
pred initRedTurn { all b: Board | initial[b] implies Redturn[b] else not Redturn[b]}

-- there is a board where it is Red's turn
pred someRedTurn { some b: Board | Redturn[b]}

-- there is a board where it is Yellow's turn
pred YellowturnTest {all b: Board | Yellowturn[b]}

-- it cannot be both red and yellow's turn
pred RedYellowTurnExclusive {
    all b: Board | not (Redturn[b] and Yellowturn[b])
}

-- a player has won
pred winningTest {
    some b: Board, p: Player | winning[b, p]
}

-- a player has won by getting 4 in a row
pred winningRowTest {
    some r, c: Int, b: Board, p: Player | {
        b.board[r][c] = p and
        b.board[r][add[c, 1]] = p and
        b.board[r][add[c, 2]] = p and
        b.board[r][add[c, 3]] = p
    }
}

-- a player has won by getting 4 in a col
pred winningColTest {
    some r, c: Int, b: Board, p: Player | {
        b.board[r][c] = p and
        b.board[add[r, 1]][c] = p and
        b.board[add[r, 2]][c] = p and
        b.board[add[r, 3]][c] = p
    }
}

-- a player has won by getting 4 in a diagonal
pred winningDiagonalTest {
    some r, c: Int, b: Board, p: Player | {
        b.board[r][c] = p and
        b.board[add[r, 1]][add[c, 1]] = p and
        b.board[add[r, 2]][add[c, 2]] = p and
        b.board[add[r, 3]][add[c, 3]] = p
    }
}

-- when one wins, the next state should still have the same player winning
pred winningPreservedCounterexample {
  some pre, post: Board | {
    some row, col: Int, p: Player | 
      move[pre, row, col, p, post]
    winning[pre, Red]
    not winning[post, Red]
  }
}

pred ValidMoveResultsInOccupiedSquare {
    all pre, post: Board, row, col: Int, turn: Player | 
        move[pre, row, col, turn, post] implies post.board[row][col] = turn
}


-- made a move on a board
pred moved[b: Board] { 
    some post: Board, r,c: Int, p: Player | 
        move[b, r, c, p, post] }

pred didntDoNothing[b: Board] {
    not { some post: Board | doNothing[b, post]} }

example RedMiddleOturn is {YellowturnTest} for {
  Board = `Board0
  Red = `Red0
  Yellow = `Yellow0
  Player = Red + Yellow --`X0 + `O0
  `Board0.board =  (1, 1) -> `Red0 
}
