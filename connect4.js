require("d3");
d3.selectAll("svg > *").remove();

//svg rough script for visualizer - NOT connected to sterling
//only for mock data below

const numRows = 6;
const numCols = 6;
const cellSize = 40;

function printValue(row, col, yoffset, value) {
  d3.select(svg)
    .append("text")
    .style("fill", value === "R" ? "red" : "yellow")
    //centering
    .attr("x", col * cellSize + cellSize / 2 + 10)
    .attr("y", row * cellSize + yoffset + cellSize / 2 + 10)
    .attr("text-anchor", "middle")
    .attr("dominant-baseline", "central")
    .text(value);
}

function drawLines(yoffset) {
  // horizontal lines
  for (let i = 0; i <= numRows; i++) {
    d3.select(svg)
      .append("line")
      .attr("x1", 10)
      .attr("y1", yoffset + i * cellSize + 10)
      .attr("x2", 10 + numCols * cellSize)
      .attr("y2", yoffset + i * cellSize + 10)
      .attr("stroke", "black")
      .attr("stroke-width", 1);
  }
  //vertical lines
  for (let i = 0; i <= numCols; i++) {
    d3.select(svg)
      .append("line")
      .attr("x1", i * cellSize + 10)
      .attr("y1", yoffset + 10)
      .attr("x2", i * cellSize + 10)
      .attr("y2", yoffset + numRows * cellSize + 10)
      .attr("stroke", "black")
      .attr("stroke-width", 1);
  }
}

function printBoard(board, yoffset) {
  const boardArray = Array.from({ length: numRows }, () =>
    new Array(numCols).fill(" ")
  );
  board.forEach((move) => {
    const row = move["row"] - 1;
    const col = move["col"] - 1;
    const player = move["player"] === "Red0" ? "R" : "Y";
    boardArray[row][col] = player;
  });

  for (let r = 0; r < numRows; r++) {
    for (let c = 0; c < numCols; c++) {
      printValue(r, c, yoffset, boardArray[r][c]);
    }
  }

  drawLines(yoffset);
  d3.select(svg)
    .append("rect")
    .attr("x", 10)
    .attr("y", yoffset + 10)
    .attr("width", numCols * 40)
    .attr("height", numRows * 40)
    .attr("stroke-width", 2)
    .attr("stroke", "black")
    .attr("fill", "transparent");
}

//mock data
const boards = [
  // state 1
  [{ row: 3, col: 2, player: "Red0" }],
  // state 2
  [
    { row: 3, col: 2, player: "Red0" },
    { row: 2, col: 2, player: "Yellow0" },
  ],
  // state 3
  [
    { row: 3, col: 2, player: "Red0" },
    { row: 2, col: 2, player: "Yellow0" },
    { row: 1, col: 5, player: "Red0" },
    { row: 6, col: 4, player: "Yellow0" },
  ],
];

let offset = 0;
boards.forEach((board) => {
  printBoard(board, offset);
  offset += numRows * cellSize + 20;
});
