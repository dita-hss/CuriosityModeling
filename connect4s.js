require("d3");
d3.selectAll("svg > *").remove();

// svg final script for visualizer - connected to sterling
// uses atoms from froglet

// hardcode some values - unsure how to obtain from froglet
const numRows = 6; //maxrow+1
const numCols = 6; //maxcol+1
const cellSize = 20;
const boardsPerColumn = 5;

// invert board bc svg starts from top left
function printValue(row, col, xoffset, yoffset, value) {
  let invertedRow = numRows - 1 - row;

  d3.select(svg)
    .append("text")
    .style("fill", value === "R" ? "red" : "blue")
    .attr("x", xoffset + col * cellSize + cellSize / 2)
    .attr("y", yoffset + invertedRow * cellSize + cellSize / 2)
    .attr("text-anchor", "middle")
    .attr("dominant-baseline", "central")
    .text(value);
}

function drawLines(xoffset, yoffset) {
  for (let i = 0; i <= numRows; i++) {
    let invertedRow = numRows - i;

    d3.select(svg)
      .append("line")
      .attr("x1", xoffset)
      .attr("y1", yoffset + invertedRow * cellSize)
      .attr("x2", xoffset + numCols * cellSize)
      .attr("y2", yoffset + invertedRow * cellSize)
      .attr("stroke", "black")
      .attr("stroke-width", 1);
  }
  for (let i = 0; i <= numCols; i++) {
    d3.select(svg)
      .append("line")
      .attr("x1", xoffset + i * cellSize)
      .attr("y1", yoffset)
      .attr("x2", xoffset + i * cellSize)
      .attr("y2", yoffset + numRows * cellSize)
      .attr("stroke", "black")
      .attr("stroke-width", 1);
  }
}

function printBoard(board, xoffset, yoffset) {
  for (let row = 0; row <= numRows; row++) {
    for (let col = 0; col <= numCols; col++) {
      let player = board.board[row][col];
      console.log(player);
      let value = "";
      if (player === Player.atom("Red0")) {
        value = "R";
      } else if (player === Player.atom("Yellow0")) {
        value = "Y";
      }
      printValue(row, col, xoffset, yoffset, value);
    }
  }

  drawLines(xoffset, yoffset);
  d3.select(svg)
    .append("rect")
    .attr("x", xoffset)
    .attr("y", yoffset)
    .attr("width", numCols * cellSize)
    .attr("height", numRows * cellSize)
    .attr("stroke-width", 2)
    .attr("stroke", "black")
    .attr("fill", "transparent");
}

var yOffset = 1;
var xOffset = 1;

// in order to see more than 20 boards states- this line has to be altered
for (let b = 1; b <= 20; b++) {
  if (Board.atom("Board" + b) != null) {
    printBoard(Board.atom("Board" + b), xOffset, yOffset);
    yOffset += numRows * cellSize + 10;

    if (b % boardsPerColumn === 0) {
      xOffset += numCols * cellSize + 10;
      yOffset = 1;
    }
  }
}