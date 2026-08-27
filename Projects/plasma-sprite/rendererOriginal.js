const canvas = document.getElementById("virescent");
const ctx = canvas.getContext("2d");

let W, H, DPR;
function resize() {
  DPR = window.devicePixelRatio || 1;
  W = window.innerWidth;
  H = window.innerHeight;
  canvas.width = W * DPR;
  canvas.height = H * DPR;
  canvas.style.width = W + "px";
  canvas.style.height = H + "px";
  ctx.setTransform(DPR, 0, 0, DPR, 0, 0);
}
window.addEventListener("resize", resize);
resize();

/* ------------------------------ */
/* CURSOR STATE (passive)         */
/* ------------------------------ */

const cursor = { x: -9999, y: -9999 };
window.addEventListener("mousemove", e => {
  cursor.x = e.clientX;
  cursor.y = e.clientY;
});

/* ------------------------------ */
/* TIME / ALIASING SYSTEM         */
/* ------------------------------ */

let t = 0;
let timeRate = 1;
let shutter = 1;

function updateTime() {
  if (Math.random() < 0.01) {
    shutter = Math.random() < 0.5 ? 0.25 : 2.0;
  }
  if (Math.random() < 0.005) {
    timeRate = 0.2 + Math.random() * 1.2;
  }
  t += timeRate * shutter;
}

/* ------------------------------ */
/* ORGANISM BODY                  */
/* ------------------------------ */

const body = {
  x: W / 2,
  y: H / 2,
  vx: 0.8,
  vy: -0.6,
  hug: 0,
  phase: Math.random() * Math.PI * 2
};

// elastic containment (liquid walls)
const margin = 80;

if (body.x < -margin) body.vx += 0.6;
if (body.x > W + margin) body.vx -= 0.6;
if (body.y < -margin) body.vy += 0.6;
if (body.y > H + margin) body.vy -= 0.6;

/* ------------------------------ */
/* CORE DRAW                      */
/* ------------------------------ */

function drawCore(x, y, phase) {
  const r = 26 + Math.sin(phase * 0.6) * 8;
  const g = ctx.createRadialGradient(x, y, 2, x, y, r);
  g.addColorStop(0, "rgba(255,255,255,0.95)");
  g.addColorStop(0.4, "rgba(120,200,255,0.7)");
  g.addColorStop(1, "rgba(40,80,140,0)");
  ctx.fillStyle = g;
  ctx.beginPath();
  ctx.arc(x, y, r, 0, Math.PI * 2);
  ctx.fill();
}

/* ------------------------------ */
/* AURA / GILL RINGS              */
/* ------------------------------ */

function drawAura(x, y, phase, offset) {
  ctx.save();
  ctx.globalCompositeOperation = "lighter";
  ctx.strokeStyle = `hsla(${(phase * 40) % 360},90%,65%,0.25)`;
  ctx.lineWidth = 2;

  ctx.beginPath();
  for (let i = 0; i <= Math.PI * 2; i += 0.25) {
    const rr =
      48 +
      Math.sin(i * 2 + phase * 0.7 + offset) * 14 +
      Math.sin(phase + offset) * 6;
    const px = x + Math.cos(i) * rr;
    const py = y + Math.sin(i) * rr;
    if (i === 0) ctx.moveTo(px, py);
    else ctx.lineTo(px, py);
  }
  ctx.closePath();
  ctx.stroke();
  ctx.restore();
}

/* ------------------------------ */
/* TELEPORT BLIP                  */
/* ------------------------------ */

function teleport() {
  body.x = Math.random() * W;
  body.y = Math.random() * H;
  body.vx = (Math.random() - 0.5) * 2;
  body.vy = (Math.random() - 0.5) * 2;
}

/* ------------------------------ */
/* MAIN LOOP                      */
/* ------------------------------ */

function loop() {
  updateTime();
  ctx.clearRect(0, 0, W, H);

  body.phase += 0.02;

  // ambient drift (liquid, magnetic)
  body.vx += Math.sin(t * 0.01 + body.phase) * 0.02;
  body.vy += Math.cos(t * 0.013 + body.phase) * 0.02;

  // accidental cursor kiss
  const dx = cursor.x - body.x;
  const dy = cursor.y - body.y;
  const dist = Math.hypot(dx, dy);

  if (dist < 120 && body.hug <= 0 && Math.random() < 0.02) {
    body.hug = 50;
  }

  if (body.hug > 0) {
    body.vx += dx * 0.0006;
    body.vy += dy * 0.0006;
    body.vx *= 0.94;
    body.vy *= 0.94;
    body.hug--;
  }

  // integrate
  body.x += body.vx;
  body.y += body.vy;

  // soft containment (not bounce)
  body.x += (W / 2 - body.x) * 0.0004;
  body.y += (H / 2 - body.y) * 0.0004;

  // rare teleport glitch
  if (Math.random() < 0.001) teleport();

  // draw layers
  drawAura(body.x, body.y, t, +0.9);
  drawAura(body.x, body.y, t, -0.9);
  drawCore(body.x, body.y, t);

  requestAnimationFrame(loop);
}

loop();
