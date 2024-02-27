# CuriosityModeling

### Project Objective: What are you trying to model? Include a brief description that would give someone unfamiliar with the topic a basic understanding of your goal.

We modeled the game of connect4. To run the program, you can use the statement run { game_trace and any_winner_exists } for ?? Board for {next is linear}. game_trace specifies the valid sequences of boards as the game progresses, and winner exists constrains the game to finish with a winner (optional). You can also enforce winningDiagonallyExists if interested in games ending in diagonals. next is linear requires that the next field progresses and is acyclic, so the boards are sequential with respect to time. 

### Model Design and Visualization: Give an overview of your model design choices, what checks or run statements you wrote, and what we should expect to see from an instance produced by the Sterling visualizer. How should we look at and interpret an instance created by your spec? Did you create a custom visualization, or did you use the default?

In our model design, we have sigs representing our players Red and Yellow. We also have a sig for a board, with a field representing a map from a 2D array index to a player. This represents player "filling" up the board. We constrain the board to be wellformed, while also adding predicates to always be either red or yellows turn, meaning the game is balanced. We have a predicate to decide whether or not a player has won on the given board. We use these predicates to determine what a move looks like in our model in the move predicate, which steps from one board to another using guard and action. The game_traces enforces that from one game state to the next, we must either make a move or do nothing, where do nothing only occurs if a player has won already. For more detail on these methods, please see the inline comments. 

From an instance of our visualizer, you should expect to see a sequence of boards with red and yellow markers being added as moves. To run our custom visualizer, go to the script tab and press run. The sequences of boards is vertical (i.e top left is first board, right under is second board, etc.). 

### Signatures and Predicates: At a high level, what do each of your sigs and preds represent in the context of the model? Justify the purpose for their existence and how they fit together.

Our important signatures are our players and the board. These are essential componenets of the game that helps us model the state of the board and what players fit into the board. Our game signature was added in order to model traces and progress through mutliple boards to create a game. Our most high level predicates include game_traces, winning, and balanced. Other predicates were explained above, but we will go into depth on the importance of these predicates. 

Our balanced predicate enforces that it is always Red or Yellow's turn. We define a player's turn by the number of pieces of the board at one time. If red and yellow pieces are equal, then it is Red's turn, but if red has one more piece than yellow, it is Yellow's turn. One of these must be true at all times for the game to be balanced. 

Our winning predicate checks if there is a winner for a certain board and player. This predicate checks for vertical or horizontal or diagonal winning by checking all the board indices for 4 consecutive pieces of the same player. The predicate is used to stop the game once a player has won, and enforce models that contain a winning player. 

Our game_traces predicate checks that for every iteration of our game progressing board, there must a move made or nothing done as the result of someone has already won. This allows us to model entire games rather than just moves or certain boards. We can specify an amount of boards we want an enforce linearity and game_traces, and the result will be valid connect4 board sequences that progress from board to board. 

### Testing: What tests did you write to test your model itself? What tests did you write to verify properties about your domain area? Feel free to give a high-level overview of this.

TODO

### Documentation: Make sure your model and test files are well-documented. This will help in understanding the structure and logic of your project.

Please see inline comments for further description on all predicates and signatures. 

### Notes

The tic-tac-toe model from class was used to develop the foundation of this model. 
