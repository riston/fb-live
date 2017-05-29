
// Stylesheets
import "./maze.css"

// Modules
import "phoenix_html";
import socket from "../socket";

const CHANNEL_NAME = "command:lobby";

const select = document.querySelector.bind(document);

const kanvas = select("#kanvas");
const [canvasWidth, canvasHeight] = [kanvas.width, kanvas.height];
const ctx = kanvas.getContext("2d");

const ACTORS = {
  N: 1, S: 2,
  E: 4, W: 8,
  SP: 16, EP: 32,
};

const BLOCK_SIZE = 30;

const BORDER_COLOR = "#FFF";

const SPRITE_COLOR = "#F22";
const SPRITE_STROKE_COLOR = "#F99";

const END_POINT_COLOR = "#2F2";
const END_POINT_STROKE_COLOR = "#9F9";

const isNorth = x => x & ACTORS.N;
const isSouth = x => x & ACTORS.S;
const isWest = x => x & ACTORS.W;
const isEast = x => x & ACTORS.E;
const isCurrent = x => x & ACTORS.SP;
const isEndPoint = x => x & ACTORS.EP;

const line = (ctx) => (x1, y1, x2, y2) => {
  ctx.beginPath();      
  ctx.moveTo(x1, y1);
  ctx.lineTo(x2, y2);
  ctx.stroke();
};

const circle = (ctx) => (cx, cy, radius) => {
    ctx.beginPath();
    ctx.arc(cx, cy, radius, 0, 2 * Math.PI, false);
};

const currentPosition = (ctx) => (cx, cy, width) => {
      circle(ctx)(cx, cy, width / 4);
      ctx.lineWidth = 3;
      ctx.fillStyle = END_POINT_COLOR;
      ctx.strokeStyle = END_POINT_STROKE_COLOR;
      ctx.fill();
      ctx.stroke();
};

const endPosition = (ctx) => (cx, cy, width) => {
      circle(ctx)(cx, cy, width / 4);
      ctx.lineWidth = 3;
      ctx.fillStyle = SPRITE_COLOR;
      ctx.strokeStyle = SPRITE_STROKE_COLOR;
      ctx.fill();
      ctx.stroke();
}

const clear = (ctx) => ctx.clearRect(0, 0, canvasWidth, canvasHeight);

function renderField({ ctx, field, size }) {
  const width = BLOCK_SIZE;
  const widthH2 = width / 2;

  const lineWidth = 6;
  const lineWidthH2 = lineWidth / 2;
  const drawLine = line(ctx);
  const drawCircle = circle(ctx);
  const current = currentPosition(ctx);
  const end = endPosition(ctx);

  clear(ctx);
  ctx.save();
  ctx.translate(50, 50);

  for (let i = 0; i < size * size; i++) {
    let x = i % size;
    let y = Math.floor(i / size);
    const value = field[i];

    ctx.strokeStyle = BORDER_COLOR;
    ctx.lineWidth = 6;

    if (!isNorth(value)) {
      const x1 = x * width;
      const y1 = y * width;
      const x2 = x1 + width;
      const y2 = y1;
      
      drawLine(x1, y1, x2, y2);
    }

    if (!isSouth(value)) {
      const x1 = x * width;
      const y1 = y * width + width;
      const x2 = x1 + width;
      const y2 = y1;
      
      drawLine(x1, y1, x2, y2);
    }

    if (!isEast(value)) {
      const x1 = x * width + width;
      const y1 = y * width;
      const x2 = x1;
      const y2 = y1 + width;
      
      drawLine(x1, y1, x2, y2);
    }

    if (!isWest(value)) {
      const x1 = x * width;
      const y1 = y * width;
      const x2 = x1;
      const y2 = y1 + width;

      drawLine(x1, y1, x2, y2);
    }

    if (isEndPoint(value)) {
      const [cx, cy] = [
        x * width + widthH2, 
        y * width + widthH2
      ];
      end(cx, cy, width);
    } 

    if (isCurrent(value)) {
      const [cx, cy] = [
        x * width + widthH2, 
        y * width + widthH2
      ];
      current(cx, cy, width);
    }
     
  }
  ctx.restore();
}

const renderText = ({ ctx, level, status, total_moves }) => {
  ctx.save();
  ctx.font = "bold 60px Verdana";
  ctx.fillStyle = "#3f3";
  if ("win" === status) {
    ctx.fillText("Next level!", 20, 160);
  }

  ctx.font = "bold 20px Verdana";
  ctx.fillText(`Level: ${level}`, 50, 30);
  ctx.fillText(`Moves: ${total_moves}`, 160, 30);

  endPosition(ctx)(55, canvasHeight - 30, BLOCK_SIZE);
  ctx.fillText("End point", 75, canvasHeight - 23);
  
  currentPosition(ctx)(200, canvasHeight - 30, BLOCK_SIZE);
  ctx.fillText("My position", 220, canvasHeight - 23);
  ctx.restore();
};

const renderMaze = (state) => {
  const { grid, status, level, total_moves } = state;
  const size = Math.sqrt(grid.length);

  console.log("Render maze", state);
  renderField({ ctx, field: grid, size });
  renderText({ ctx, level, status, total_moves });
};

const onOK = state => {
  console.log("Joined successfully", state);
  renderMaze(state);
}
const onError = response => console.log("Unable to join ", response);

// Now that you are connected, you can join channels with a topic:
const channel = socket.channel(CHANNEL_NAME, {});
channel.join()
  .receive("ok", onOK)
  .receive("error", onError);

channel.on("current", state => renderMaze(state));
