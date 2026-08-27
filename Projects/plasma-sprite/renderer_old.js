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

/* -------------------------------------------------- */
/* CORE TIME SYSTEM (intentional temporal aliasing)   */
/* -------------------------------------------------- */

let t = 0;
let timeRate = 1;
let shutter = 1;

function updateTime() {
  // slow-motion stutter + aliasing illusion
  if (Math.random() < 0.005) {
    shutter = Math.random() < 0.5 ? 0.25 : 2;
  }
  if (Math.random() < 0.003) {
    timeRate = Math.random() * 0.8 + 0.2;
  }
  t += timeRate * shutter;
}

/* -------------------------------------------------- */
/* ENTITY STATE                                       */
/* -------------------------------------------------- */

const center = { x: W / 2, y: H / 2 };
let vel = { x: 0.6, y: -0.4 };

const glyphSet =
  "ƹƨʊɔəʢʺΩΔΦΨπ∞±≠∂∫∑µ∴∵ꝋxz?¿";

const glyphs = [];

/* -------------------------------------------------- */
/* PLASMA CORE (burning bush / mobius knot)           */
/* -------------------------------------------------- */

function drawCore(x, y, phase) {
  const r = 28 + Math.sin(phase * 0.6) * 8;

  const grad = ctx.createRadialGradient(x, y, 2, x, y, r);
  grad.addColorStop(0, "rgba(255,255,255,0.9)");
  grad.addColorStop(0.4, "rgba(120,200,255,0.7)");
  grad.addColorStop(1, "rgba(40,80,140,0.0)");

  ctx.beginPath();
  ctx.fillStyle = grad;
  ctx.arc(x, y, r, 0, Math.PI * 2);
  ctx.fill();
}

/* -------------------------------------------------- */
/* AURA FIELD (lags or leads time)                    */
/* -------------------------------------------------- */

function drawAura(x, y, phase, offset) {
  ctx.save();
  ctx.globalCompositeOperation = "lighter";
  ctx.strokeStyle = `hsla(${(phase * 40) % 360},90%,65%,0.25)`;
  ctx.lineWidth = 2;

  ctx.beginPath();
  for (let i = 0; i < Math.PI * 2; i += 0.25) {
    const rr =
      50 +
      Math.sin(i * 2 + phase * 0.7 + offset) * 12 +
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

/* -------------------------------------------------- */
/* GLYPH EXHAUST                                      */
/* -------------------------------------------------- */

function spawnGlyph(x, y) {
  glyphs.push({
    x,
    y,
    vx: (Math.random() - 0.5) * 1.5,
    vy: (Math.random() - 0.5) * 1.5,
    life: 200 + Math.random() * 200,
    ch: glyphSet[Math.floor(Math.random() * glyphSet.length)],
    drift: Math.random() * Math.PI * 2
  });
}

function drawGlyphs() {
  ctx.font = "16px monospace";
  glyphs.forEach(g => {
    ctx.fillStyle = `hsla(${(g.life * 2) % 360},80%,70%,0.7)`;
    ctx.fillText(g.ch, g.x, g.y);
  });
}

function updateGlyphs() {
  for (let i = glyphs.length - 1; i >= 0; i--) {
    const g = glyphs[i];
    g.drift += 0.03;
    g.x += g.vx + Math.sin(g.drift) * 0.3;
    g.y += g.vy + Math.cos(g.drift) * 0.3;
    g.life--;

    // mutation event
    if (Math.random() < 0.01) {
      g.ch =
        Math.random() < 0.5
          ? "x"
          : glyphSet[Math.floor(Math.random() * glyphSet.length)];
    }

    if (g.life <= 0) glyphs.splice(i, 1);
  }
}

/* -------------------------------------------------- */
/* SPACE WARP / PRISM EVENT                           */
/* -------------------------------------------------- */

function warpPulse() {
  ctx.save();
  ctx.globalCompositeOperation = "overlay";
  ctx.fillStyle = "rgba(180,220,255,0.08)";
  ctx.fillRect(0, 0, W, H);
  ctx.restore();
}

/* -------------------------------------------------- */
/* MAIN LOOP                                          */
/* -------------------------------------------------- */

function loop() {
  updateTime();

  ctx.clearRect(0, 0, W, H);

  // drift motion
  center.x += vel.x;
  center.y += vel.y;

  if (center.x < 100 || center.x > W - 100) vel.x *= -1;
  if (center.y < 100 || center.y > H - 100) vel.y *= -1;

  // occasional glyph emission
  if (Math.random() < 0.25) spawnGlyph(center.x, center.y);

  // aura lead/lag illusion
  drawAura(center.x, center.y, t, +0.8);
  drawAura(center.x, center.y, t, -0.8);

  // plasma core
  drawCore(center.x, center.y, t);

  updateGlyphs();
  drawGlyphs();

  // rare warp shimmer
  if (Math.random() < 0.01) warpPulse();

  requestAnimationFrame(loop);
}

loop();
