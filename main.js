// Chashi · Ночная чайная — desktop shell. Created by Ernomoon (https://t.me/Ernomoon)
const { app, BrowserWindow, shell, Menu, nativeTheme } = require('electron');
const path = require('path');

app.setAppUserModelId('com.ernomoon.chashi');
if (!app.requestSingleInstanceLock()) app.quit();

let win;
function createWindow() {
  nativeTheme.themeSource = 'dark';
  win = new BrowserWindow({
    width: 1280,
    height: 820,
    minWidth: 380,
    minHeight: 600,
    show: false,
    backgroundColor: '#03040e',
    title: 'Ночная чайная',
    icon: path.join(__dirname, 'app', 'icon.png'),
    titleBarStyle: 'hidden',
    titleBarOverlay: { color: '#05060f', symbolColor: '#e6c587', height: 34 },
    autoHideMenuBar: true,
    webPreferences: { backgroundThrottling: false, contextIsolation: true, sandbox: true }
  });
  Menu.setApplicationMenu(null);
  win.loadFile(path.join(__dirname, 'app', 'index.html'));
  win.once('ready-to-show', () => win.show());
  // Ссылки (Telegram и т.п.) открываются в обычном браузере
  win.webContents.setWindowOpenHandler(({ url }) => {
    if (/^https?:/i.test(url)) shell.openExternal(url);
    return { action: 'deny' };
  });
  win.webContents.on('will-navigate', (e, url) => {
    if (!url.startsWith('file:')) { e.preventDefault(); shell.openExternal(url); }
  });
}

app.on('second-instance', () => {
  if (!win) return;
  if (win.isMinimized()) win.restore();
  win.focus();
});
app.whenReady().then(createWindow);
app.on('window-all-closed', () => app.quit());
