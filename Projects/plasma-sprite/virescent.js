const canvas = document.getElementById('world');
const ctx = canvas.getContext('2d');

function resize() {
  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;
}
resize();
window.addEventListener('resize', resize);

const glyphs = const glyphs = ["᚛", "᚜", "ᛝ", "۞", "₪", "✧", "ᚾ", "߷", "౨", "ᔑ", "ﺝ", "ﬡ", "ꭍ", "Ω", "Σ","Ⰹ", "Ⱑ", "Ⰿ", "Ⰴ", "-", "+", "÷", "x", "z"];

let entity = {
  x: Math.random() * canvas.width,
  y: Math.random() * canvas.height,
  vx: 0,
  vy: 0,
  energy: 1,
  tail: [],
  mode: 'idle',
  glyph: glyphs[0],
  nextThought: performance.now() + 2000
};

document.addEventListener('mousemove', e => {
  const dx = e.clientX - entity.x;
  const dy = e.clientY - entity.y;
  const d = Math.hypot(dx, dy);
  if (d > 300) {
    entity.vx += dx * 0.0004;
    entity.vy += dy * 0.0004;
    entity.mode = 'curious';
  }
});

function think(time) {
  if (time > entity.nextThought) {
    entity.mode = Math.random() < 0.4 ? 'idle' : 'drift';
    entity.glyph = glyphs[Math.floor(Math.random()*glyphs.length)];
    entity.nextThought = time + 1500 + Math.random()*3000;
  }
}

// Adjusted movement logic to slow down the sprite and reduce erratic behavior
function update() {
  // Add damping to velocity to prevent compounding errors
  entity.vx += (Math.random() - 0.5) * 0.01; // Reduced random influence
  entity.vy += (Math.random() - 0.5) * 0.01;

  entity.vx *= 0.95; // Increased damping factor
  entity.vy *= 0.95;

  // Update position
  entity.x += entity.vx;
  entity.y += entity.vy;

  // Keep the entity within canvas bounds
  entity.x = clamp(entity.x, 0, canvas.width);
  entity.y = clamp(entity.y, 0, canvas.height);

  // Add logic to spend more time in a solid state
  if (entity.mode === 'idle') {
    entity.energy = Math.min(entity.energy + 0.01, 1); // Gradual energy recovery
  } else {
    entity.energy = Math.max(entity.energy - 0.01, 0); // Gradual energy depletion
  }

  // Update tail for smoother motion
  entity.tail.push({ x: entity.x, y: entity.y });
  if (entity.tail.length > 20) {
    entity.tail.shift();
  }
}

function draw() {
  ctx.clearRect(0,0,canvas.width,canvas.height);

  // tail
  entity.tail.forEach((p,i) => {
    ctx.globalAlpha = p.life;
    ctx.fillStyle = 'rgba(120,255,200,0.25)';
    ctx.fillText(glyphs[i % glyphs.length], p.x, p.y);
    p.life *= 0.96;
  });

  // body
  ctx.globalAlpha = 1;
  ctx.font = '28px serif';
  ctx.fillStyle = 'rgba(180,255,220,0.95)';
  ctx.fillText(entity.glyph, entity.x, entity.y);
}

function loop(time) {
  think(time);
  update();
  draw();
  requestAnimationFrame(loop);
}

loop();
