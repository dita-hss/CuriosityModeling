#lang forge/bsl 
-- ^ "Froglet" 

abstract sig Player {} 
one sig Red, Yellow extends Player {} 

sig Board { 
    board: pfunc Int -> Int -> Player
}

fun MIN: one Int { 0 }
fun MAX: one Int { 6 }

-- predicate: rule out "garbage"
pred wellformed[b: Board] {
    all row, col: Int | {
            (row < MIN or row > MAX or 
            col < MIN or col > MAX) implies
                no b.board[row][col]
    } 
}

-- show me a world in which...
-- run {some b: Board | wellformed[b]}

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
    Red = `X0
    Yellow = `O0
    Player = Red + O
    `Board0.board = (-1,0) -> Red + 
                    (0,1) -> Red + 
                    (0,2) -> Red
}

-------------------------------------
-- Wednesday, Jan 31
-------------------------------------

/* An initial board */
pred initial[b: Board] {
    all row, col: Int | no b.board[row][col]
}

/* Whose turn is it (if anyone's)? */
pred Redturn[b: Board] {
    #{row, col: Int | b.board[row][col] = Red} 
    = 
    #{row, col: Int | b.board[row][col] = Yellow} 
}

pred Yellowturn[b: Board] {
    #{row, col: Int | b.board[row][col] = Red} 
    = 
    add[#{row, col: Int | b.board[row][col] = Yellow}, 1]
}

pred balanced[b: Board] {
    Redturn[b] or Yellowturn[b]
}

pred winning[b: Board, p: Player] {
    -- 3 in a row
    (some r, c: Int | { 
        b.board[r][c] = p and
        b.board[r][add[c, 1]] = p and
        b.board[r][add[c, 2]] = p and
        b.board[r][add[c, 3]] = p
    })
    or
    -- 3 in a col 
    (some r, c: Int | { 
        b.board[r][c] = p and
        b.board[add[r, 1]][c] = p and
        b.board[add[r, 2]][c] = p and
        b.board[add[r, 3]][c] = p
    })
    or 
    (some r, c: Int | { 
        b.board[r][c] = p and
        b.board[add[r, 1]][add[c, 1]] = p and
        b.board[add[r, 2]][add[c, 2]] = p and
        b.board[add[r, 3]][add[c, 3]] = p
    })
    or 
    (some r, c: Int | { 
        b.board[r][c] = p and
        b.board[subtract[r, 1]][subtract[c, 1]] = p and
        b.board[subtract[r, 2]][subtract[c, 2]] = p and
        b.board[subtract[r, 3]][subtract[r, 3]] = p
    })

}

-- "transition relation"
pred move[pre: Board, 
          row, col: Int, 
          turn: Player, 
          post: Board] {
    -- guard: conditions necessary to make a move  
    -- cant move somewhere with an existing mark
    -- valid move location
    -- it needs to be the player's turn 
    no pre.board[row][col]
    turn = Red implies Redturn[pre]
    turn = Yellow implies Yellowturn[pre]

    -- prevent winning boards from progressing
    all p: Player | not winning[pre, p]

    -- enforce valid move index
    row >= MIN
    row <= MAX
    col >= MIN
    col <= MAX

    -- balanced game
    -- game hasn't been won yet
    -- if it's a tie can't move 
    -- board needs to be well-formed 

    -- action: effects of making a move

    -- mark the location with the player 
    post.board[row][col] = turn 
    -- updating the board; check for winner or tie 
    -- other squares stay the same  ("frame condition")
    all row2: Int, col2: Int | (row!=row2 or col!=col2) implies {
        post.board[row2][col2] = pre.board[row2][col2]
    }
}

pred doNothing[pre, post: board] {
    -- guard
    some p: Player | winning[pre, p]

    -- action
    all r, c: Int | {
        pre.board[r][c] = post.board[r][c]
    }
}

-------------------------------------
-- Friday, Feb 02
-------------------------------------

-- What can we do with "move"?
-- Preservation: 
pred winningPreservedCounterexample {
  some pre, post: Board | {
    some row, col: Int, p: Player | 
      move[pre, row, col, p, post]
    winning[pre, Red]
    not winning[post, Red]
  }
}
test expect {
  winningPreserved: { 
    allBoardsWellformed
    winningPreservedCounterexample } is unsat
}

-- This gives Forge a visualizer script to automatically run, without requiring you
-- to copy-paste it into the script editor. CHANGES WILL NOT BE REFLECTED IN THE FILE!
option run_sterling "ttt_viz.js"

// run {
//     wellformed 
//     some pre, post: Board | {
//         some row, col: Int, p: Player | 
//             move[pre, row, col, p, post]
//     }
// }

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
    }}
}
// run { 
//     game_trace
//     all b: Board | { 
//         some r,c: Int | {
//             r >=0 r <= 2 
//             c >=0 c <= 2
//             no b.board[r][c]
//         }
//     }
// } for 10 Board for {next is linear}
// // ^ the annotation is faster than the constraint


-------------------------------
-- Validation
-------------------------------

pred moved[b: Board] { 
    some post: Board, r,c: Int, p: Player | 
        move[b, r, c, p, post] }
pred didntDoNothing[b: Board] {
    not { some post: Board | doNothing[b, post]} }
// assert all b: Board | 
//   moved[b] is sufficient for didntDoNothing[b]
// sufficient ~= implies
// necessary ~= implies-in-reverse


// assert all b: Board | 
//   moved[b] is necessary for didntDoNothing[b]
// -- ^ This fails, perhaps because the _final_ board won't 
// --   be able to take either transition (perhaps, but we didn't invoke traces)...
//  ... Why DOES this fail?






---------------------------------------------------------------
-- Feb 9 -- more validation, assertions, inductive preservation
---------------------------------------------------------------


-- assertions (in many ways) generalize examples. the 3 tests below
-- check for the same shape of behavior:

-- Example (make sure to define *ALL SIGS AND FIELDS*):

pred someOTurn {some b: Board | oturn[b]}
example RedMiddleOturn is {someOTurn} for {
  Board = `Board0
  Red = `X0
  Yellow = `O0
  Player = Red + Yellow --`X0 + `O0
  `Board0.board =  (1, 1) -> `X0 
  -- no `Board0.board -- this works to say the field is empty
}

-- Assertion (without variables):
pred someXTurn {some b:Board | Redturn[b]}
pred emptySingleBoard {
  one b: Board | true
  all b: Board, r,c: Int | no b.board[r][c]
}
--  emptySingleBoard => someXTurn 
assert emptySingleBoard is sufficient for someXTurn 
-- same thing
assert someXturn is necessary for emptySingleBoard

-- Assertion (with variables):
pred emptyBoard[b: Board] { all r, c: Int | no b.board[r][c] }
assert all b: Board | emptyBoard[b] is sufficient for Redturn[b]

-- a is sufficient for b    implies
-- a is necessary for b     <===
-- This last assertion is nice and concise, but *ALSO* doesn't implicitly only 
-- check situations where there is only one Board in the world... Another advantage
-- of quantification!

---------------





-- Example: is it ever possible to reach an unbalanced state?

-- Step 1: any initial states unbalanced? 
assert all b: Board | 
  initial[b] is sufficient for balanced[b]
  for 1 Board, 3 Int

-- Step 2: any legal transitions from a balanced board to an unbalanced board?
pred moveFromBalanced[pre: Board, row, col: Int, 
       p: Player, post: board] {
  balanced[pre]
  move[pre, row, col, p, post]
}
assert all pre, post: Board, row, col: Int, p: Player | 
  moveFromBalanced[pre, row, col, p, post] is sufficient for balanced[post]
    for 2 Board, 4 Int

-- Note: we are able to get away with MUCH lower bounds using this technique. We don't need 
-- Forge to generate whole game traces; rather, we are reasoning abstractly about whether 
-- a single transition preserves balance. 

*/