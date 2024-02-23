#lang forge/bsl 
-- ^ "Froglet" 

abstract sig Player {} 
one sig Red, Yellow extends Player {} 

sig Board { 
    board: pfunc Int -> Int -> Player
}

-- global constants like this
fun MIN: one Int { 0 }
fun MAXCOL: one Int { 6 }
fun MAXROW: one Int { 7 }

-- predicate: make sure that all boatds are a certain size
pred wellformed[b: Board] {
    all row, col: Int | {
            (row < MIN or row > MAXROW or 
            col < MIN or col > MAXCOL) implies
                no b.board[row][col]
    } 
}

-- check that boards are wellformed
// run {some b: Board | wellformed[b]}

-- an intial board is one where no moves have been made
pred initial[b: Board] {
    all row, col: Int | no b.board[row][col]
}

-- it is Red's turn if the number of reds is equal to the number of yellows
pred Redturn[b: Board] {
    #{row, col: Int | b.board[row][col] = Red} 
    = 
    #{row, col: Int | b.board[row][col] = Yellow} 
}

-- it is yellow's turn if the number of reds is one more than the number of yellows
pred Yellowturn[b: Board] {
    #{row, col: Int | b.board[row][col] = Red} 
    = 
    add[#{row, col: Int | b.board[row][col] = Yellow}, 1]
}

-- make sure that the game is balanced
pred balanced[b: Board] {
    Redturn[b] or Yellowturn[b]
}

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
        b.board[subtract[r, 1]][subtract[c, 1]] = p and
        b.board[subtract[r, 2]][subtract[c, 2]] = p and
        b.board[subtract[r, 3]][subtract[r, 3]] = p
    })
}

-- from a pre board, we can make a move to a post board
pred move[pre: Board, 
          row, col: Int, 
          turn: Player, 
          post: Board] {
    -- guard: there must be some conditions that hold in order to make a move
            -- one cannot move somewhere where a player currently is
            -- valid move location
            -- it needs to be the player's turn 
    
    no pre.board[row][col]
    turn = Red implies Redturn[pre]
    turn = Yellow implies Yellowturn[pre]

    -- once a player wins the game, the game no longer progresses
    all p: Player | not winning[pre, p]

    -- enforce valid move index
    row >= MIN
    row <= MAXROW
    col >= MIN
    col <= MAXCOL

    -- mark the location with the player 
    post.board[row][col] = turn 
    -- updating the board; check for winner or tie 
    -- other squares stay the same  ("frame condition")
    all row2: Int, col2: Int | (row!=row2 or col!=col2) implies {
        post.board[row2][col2] = pre.board[row2][col2]
    }
}

pred doNothing[pre, post: board] {
    -- guard: some player
    some p: Player | winning[pre, p]

    -- action
    all r, c: Int | {
        pre.board[r][c] = post.board[r][c]
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

option run_sterling "ttt_viz.js"

one sig Game {
    first: one Board, 
    next: pfunc Board -> Board
}
pred game_trace {
    initial[Game.first]
    all b: Board | { some Game.next[b] implies {
        (some row, col: Int, p: Player | 
            move[b, row, col, p, Game.next[b]])
        or
        doNothing[b, Game.next[b]]
        -- TODO: ensure Red moves first
            -- red already always goes first due to the constraint of RedTurn/YellowTurn -amanda
    }}
}
run { 
    game_trace
    all b: Board | { 
        some r,c: Int | {
            r >=0 r <= 2 
            c >=0 c <= 2
            no b.board[r][c]
        }
    }
} for 10 Board for {next is linear}

-------------------------------------TESTING------------------------------------------------

pred allBoardsWellformed { all b: Board | wellformed[b] }
example firstRowX_wellformed is {allBoardsWellformed} for {
    Board = `Board0
    Red = `Red
    Yellow = `Yellow
    Player = Red + Yellow
    `Board0.board = (0,0) -> Red + 
                    (0,1) -> Red + 
                    (0,2) -> Red
}

example offBoardX_not_wellformed is {not allBoardsWellformed} for {
    Board = `Board0
    Red = `Red0
    Yellow = `Yellow0
    Player = Red + Yellow
    `Board0.board = (-1,0) -> Red + 
                    (0,1) -> Red + 
                    (0,2) -> Red
}

test expect {
  winningPreserved: { 
    allBoardsWellformed
    winningPreservedCounterexample } is unsat
}

pred moved[b: Board] { 
    some post: Board, r,c: Int, p: Player | 
        move[b, r, c, p, post] }
pred didntDoNothing[b: Board] {
    not { some post: Board | doNothing[b, post]} }


pred YellowturnTest {some b: Board | Yellowturn[b]}
example RedMiddleOturn is {YellowturnTest} for {
  Board = `Board0
  Red = `Red0
  Yellow = `Yellow0
  Player = Red + Yellow --`X0 + `O0
  `Board0.board =  (1, 1) -> `Red0 
  -- no `Board0.board -- this works to say the field is empty
}

-- Assertion (without variables):
pred someRedTurn {some b:Board | Redturn[b]}
pred emptySingleBoard {
  one b: Board | true
  all b: Board, r,c: Int | no b.board[r][c]
}

--  emptySingleBoard => someXTurn 
assert emptySingleBoard is sufficient for someRedTurn 
-- same thing
assert someRedTurn is necessary for emptySingleBoard

---------- FAULTY TESTS ----------------
// pred moved[b: Board] { 
//     some post: Board, r,c: Int, p: Player | 
//         move[b, r, c, p, post] }
// pred didntDoNothing[b: Board] {
//     not { some post: Board | doNothing[b, post]} }
// assert all b: Board | 
//   moved[b] is sufficient for didntDoNothing[b]
// sufficient ~= implies
// necessary ~= implies-in-reverse

// -- Assertion (with variables):
// pred emptyBoard[b: Board] { all r, c: Int | no b.board[r][c] }
// assert all b: Board | emptyBoard[b] is sufficient for Redturn[b]