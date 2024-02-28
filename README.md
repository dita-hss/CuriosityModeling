# CuriosityModeling


### Project Objective: What are you trying to model? Include a brief description that would give someone unfamiliar with the topic a basic understanding of your goal.



### Model Design and Visualization: Give an overview of your model design choices, what checks or run statements you wrote, and what we should expect to see from an instance produced by the Sterling visualizer. How should we look at and interpret an instance created by your spec? Did you create a custom visualization, or did you use the default?

Here are some runs that we ran for curiosity:
    - Games where a winner emerges in 15 moves or less
    - Games where a player wins diagonally within 15 moves where specific player scenarios (Red or Yellow) can also be explored
    - Games where the game is won after all possible moves are played
    - Games where no player wins after all possible moves are made

Visualization with Sterling:
    - With the use of a custom SVG script, one can expect to look at a physical board with the arrangement of the Y and B pieces to understand the game state, turn, and potential winning conditions.
    - It is possible to look at the table to gain an understanding of the dynamics as well. Here, one would be looking at the board states to understand the where each player has moved and which player has moved. 


### Signatures and Predicates: At a high level, what do each of your sigs and preds represent in the context of the model? Justify the purpose for their existence and how they fit together.



### Testing: What tests did you write to test your model itself? What tests did you write to verify properties about your domain area? Feel free to give a high-level overview of this.

Our test suites aim to test predicates with a significant roles in the model as well as some helper predicates. Below is a description of the suites and the test contained within. 

- **Wellformed Test Suite:** Checks that the game board is well-formed
    - Valid piece placements within a specified range (e.g., a 5x5 board).
    - Invalid placements outside the range, including negative coordinates.
- **Initial Test Suite:** Checks the initial state of the game.
    - Ensures an initial game board is empty.
    - Invalidates a board with any initial moves.
- **RedTurn Test Suite:** Checks scenarios where it's Red's turn.
    - Ensures Red's turn follows game rules on empty and partially filled boards.
    - Checks for contradictions and necessary conditions for Red's turn.
- **YellowTurn Test Suite:** Checks scenarios where it's Yellows's turn.
    - Validates Yellow's turn based on game state.
    - Includes necessary conditions and contradiction tests.
- **Winning Test Suite:** Tests various winning conditions.
    - Checks for horizontal, vertical, and diagonal wins.
    - Ensures no wins on an empty board.
    - Verifies that a player can't win in multiple ways on the same board.
- **Move Test Suite:** Checks the logic for making moves.
    - Ensures a valid move is possible unless the game is won or the board is full.
    - Checks correct placement of a square after a move.
    - Ensures only one piece is added per move.
- **DoNothing Test Suite:** Tests scenarios where no action is taken when a game has been won
    - Ensures the game state remains unchanged when the game is already won.


#### Documentation: Make sure your model and test files are well-documented. This will help in understanding the structure and logic of your project.

Our model and test files have been documented. 