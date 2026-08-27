const canvas = document.getElementById("world");
const ctx = canvas.getContext("2d");

canvas.width = window.innerWidth;
canvas.height = window.innerHeight;

// Organism state
let orb = {
  x: Math.random() * canvas.width,
  y: Math.random() * canvas.height,
  vx: (Math.random() - 0.5) * 2,
  vy: (Math.random() - 0.5) * 2,
  r: 18,
  hugging: false,
  hugTimer: 0
};

// Cursor state
let mouse = {
  x: null,
  y: null
};

window.addEventListener("mousemove", e => {
  mouse.x = e.clientX;
  mouse.y = e.clientY;
});

// elastic containment (liquid walls)
const margin = 80;

if (body.x < -margin) body.vx += 0.6;
if (body.x > W + margin) body.vx -= 0.6;
if (body.y < -margin) body.vy += 0.6;
if (body.y > H + margin) body.vy -= 0.6;

function update() {
  // Wander
  orb.x += orb.vx;
  orb.y += orb.vy;

  // Bounce like DVD screensaver (for now)
  if (orb.x < orb.r || orb.x > canvas.width - orb.r) orb.vx *= -1;
  if (orb.y < orb.r || orb.y > canvas.height - orb.r) orb.vy *= -1;

  // Distance to cursor
  if (mouse.x !== null) {
    const dx = mouse.x - orb.x;
    const dy = mouse.y - orb.y;
    const dist = Math.hypot(dx, dy);

    // ACCIDENTAL CONTACT → HUG
    if (dist < 40 && !orb.hugging) {
      orb.hugging = true;
      orb.hugTimer = 30; // frames
    }

    // Hug behavior
    if (orb.hugging) {
      orb.vx += dx * 0.0005;
      orb.vy += dy * 0.0005;
      orb.hugTimer--;

      if (orb.hugTimer <= 0) {
        orb.hugging = false;
      }
    }
  }
}

function draw() {
  ctx.clearRect(0, 0, canvas.width, canvas.height);

  ctx.beginPath();
  ctx.arc(orb.x, orb.y, orb.r, 0, Math.PI * 2);
  ctx.fillStyle = orb.hugging ? "rgba(0,255,200,0.9)" : "rgba(255,255,255,0.8)";
  ctx.fill();
}

function loop() {
  update();
  draw();
  requestAnimationFrame(loop);
}

loop();
