#lang forge/bsl 

open "connect4.frg"

test suite for wellformed {

    example firstRowX_wellformed is {allBoardsWellformed} for {
    Board = `Board0
    Red = `Red
    Yellow = `Yellow
    Player = Red + Yellow
    `Board0.board = (0,0) -> Red + 
                    (0,1) -> Red + 
                    (0,2) -> Red
}

}

test suite for winning {

    test expect {
      winningPreserved: { 
        allBoardsWellformed
        winningPreservedCounterexample } is unsat
}


}