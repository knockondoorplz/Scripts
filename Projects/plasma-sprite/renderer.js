const glyphs = ["ᚠ","ᚢ","ᚦ","ᚨ","ᚱ","ᚲ","ᚹ","ᛉ","ᛋ","ᛏ","ᛒ","ᛗ","ᛟ","ᛞ","ᛝ","᚛","᚜","۞","₪","✧","ᚾ","߷","౨","ᔑ","ﺝ","ﬡ","ꭍ","Ω","Σ","Ⰹ","Ⱑ","Ⰿ","Ⰴ","-","+","÷","x","z"];

const canvas = document.getElementById("virescent");
const ctx = canvas.getContext("2d");

function resize() {
  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;
}
window.addEventListener("resize", resize);
resize();

console.log("renderer alive");

let t = 0;

function loop() {
  t += 0.016;

  // ghostly persistence
  ctx.fillStyle = "rgba(20,20,20,0.25)";
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  ctx.fillStyle = "lime";
  ctx.font = "48px monospace";
  ctx.fillText("VIRESCENT ONLINE", 50, 100);

  const x = 200 + Math.sin(t) * 60;
  const y = 220 + Math.cos(t * 0.7) * 40;

  ctx.beginPath();
  ctx.arc(x, y, 6, 0, Math.PI * 2);
  ctx.fill();

  requestAnimationFrame(loop);
}

loop();
