const { app, BrowserWindow, screen } = require('electron');

function createWindow() {

  const displays = screen.getAllDisplays();

  const minX = Math.min(...displays.map(d => d.bounds.x));
  const minY = Math.min(...displays.map(d => d.bounds.y));
  const maxX = Math.max(...displays.map(d => d.bounds.x + d.bounds.width));
  const maxY = Math.max(...displays.map(d => d.bounds.y + d.bounds.height));

  const totalWidth = maxX - minX;
  const totalHeight = maxY - minY;

  console.log("Desktop span:", totalWidth, totalHeight);

  const win = new BrowserWindow({
    x: minX,
    y: minY,
    width: totalWidth,
    height: totalHeight,
    transparent: true,
    frame: false,
    resizable: false,
    hasShadow: false,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false,
    },
  });

  win.setBounds({
  x: minX,
  y: minY,
  width: totalWidth,
  height: totalHeight
  });

  win.setAlwaysOnTop(true, 'screen-saver');
  win.setVisibleOnAllWorkspaces(true);
  win.setIgnoreMouseEvents(true, { forward: true });

  win.setFullScreenable(false);

  console.log("Actual window bounds:", win.getBounds());

  win.loadFile('Virescent_Aeon.html');
}

app.whenReady().then(createWindow);
