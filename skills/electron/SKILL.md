---
name: electron
description: >
  Electron patterns for building secure, cross-platform desktop applications.
  Trigger: When building desktop apps, working with Electron main/renderer processes,
  IPC communication, native integrations, packaging, or auto-updates.
metadata:
  author: gentleman-programming
  version: "2.0"
  source: "https://github.com/Gentleman-Programming/Gentleman-Skills/tree/main/community/electron"
  scope: "general-purpose"
---

## When to Use

Load this skill when:
- Building cross-platform desktop applications
- Working with Electron main and renderer processes
- Implementing IPC (Inter-Process Communication)
- Integrating native OS features (menus, notifications, dialogs, file system)
- Choosing or implementing a renderer UI framework (React, Vue, Svelte, SvelteKit)
- Setting up auto-updates, packaging, and distribution

## Critical Patterns

### Pattern 1: Project Structure

```text
src/
|-- main/                    # Main process (Node.js)
|   |-- index.ts             # Entry point
|   |-- ipc/                 # IPC handlers
|   |   |-- handlers.ts
|   |   `-- channels.ts
|   |-- services/            # Native services (store, updater)
|   `-- windows/             # Window management
|-- preload/                 # Safe bridge API for renderer
|   `-- index.ts
|-- shared/                  # Shared types/contracts
|   `-- ipc.ts
`-- renderer/                # UI app (framework of choice)
    |-- src/
    |   |-- App.(tsx|vue|svelte)
    |   `-- lib/
    `-- index.html
```

### Pattern 2: Secure IPC Communication

Always use `contextBridge` for secure communication:

```typescript
// preload/index.ts
import { contextBridge, ipcRenderer } from 'electron';
import type { ElectronAPI, IpcChannels } from '../shared/ipc';

const electronAPI: ElectronAPI = {
  send: <T extends keyof IpcChannels>(channel: T, data: IpcChannels[T]['request']) => {
    ipcRenderer.send(channel, data);
  },
  invoke: <T extends keyof IpcChannels>(
    channel: T,
    data: IpcChannels[T]['request']
  ): Promise<IpcChannels[T]['response']> => {
    return ipcRenderer.invoke(channel, data);
  },
  on: <T extends keyof IpcChannels>(
    channel: T,
    callback: (data: IpcChannels[T]['response']) => void
  ) => {
    const subscription = (_: Electron.IpcRendererEvent, data: IpcChannels[T]['response']) => {
      callback(data);
    };
    ipcRenderer.on(channel, subscription);
    return () => ipcRenderer.removeListener(channel, subscription);
  }
};

contextBridge.exposeInMainWorld('electron', electronAPI);
```

### Pattern 3: Type-Safe IPC Contracts

Define all channels with request/response types:

```typescript
// shared/ipc.ts
export interface IpcChannels {
  'app:get-version': {
    request: void;
    response: string;
  };
  'file:read': {
    request: { path: string };
    response: { content: string } | { error: string };
  };
  'file:write': {
    request: { path: string; content: string };
    response: { success: boolean };
  };
  'dialog:open-file': {
    request: { filters?: Electron.FileFilter[] };
    response: string | null;
  };
  'store:get': {
    request: { key: string };
    response: unknown;
  };
  'store:set': {
    request: { key: string; value: unknown };
    response: void;
  };
}

export type ElectronAPI = {
  send<T extends keyof IpcChannels>(channel: T, data: IpcChannels[T]['request']): void;
  invoke<T extends keyof IpcChannels>(
    channel: T,
    data: IpcChannels[T]['request']
  ): Promise<IpcChannels[T]['response']>;
  on<T extends keyof IpcChannels>(
    channel: T,
    callback: (data: IpcChannels[T]['response']) => void
  ): () => void;
};

declare global {
  interface Window {
    electron: ElectronAPI;
  }
}
```

## Code Examples

### Example 1: Main Process Setup

```typescript
// main/index.ts
import { app, BrowserWindow } from 'electron';
import path from 'path';
import { registerIpcHandlers } from './ipc/handlers';

let mainWindow: BrowserWindow | null = null;

async function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    minWidth: 800,
    minHeight: 600,
    webPreferences: {
      preload: path.join(__dirname, '../preload/index.js'),
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: true
    }
  });

  registerIpcHandlers();

  if (process.env.NODE_ENV === 'development') {
    await mainWindow.loadURL('http://localhost:5173');
    mainWindow.webContents.openDevTools({ mode: 'detach' });
  } else {
    await mainWindow.loadFile(path.join(__dirname, '../renderer/index.html'));
  }

  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) createWindow();
});
```

### Example 2: IPC Handlers

```typescript
// main/ipc/handlers.ts
import { app, dialog, ipcMain } from 'electron';
import fs from 'node:fs/promises';
import Store from 'electron-store';

const store = new Store();

export function registerIpcHandlers() {
  ipcMain.handle('app:get-version', () => app.getVersion());

  ipcMain.handle('file:read', async (_, { path }) => {
    try {
      const content = await fs.readFile(path, 'utf-8');
      return { content };
    } catch (error) {
      return { error: (error as Error).message };
    }
  });

  ipcMain.handle('file:write', async (_, { path, content }) => {
    try {
      await fs.writeFile(path, content, 'utf-8');
      return { success: true };
    } catch {
      return { success: false };
    }
  });

  ipcMain.handle('dialog:open-file', async (_, { filters }) => {
    const result = await dialog.showOpenDialog({
      properties: ['openFile'],
      filters: filters || [{ name: 'All Files', extensions: ['*'] }]
    });
    return result.canceled ? null : result.filePaths[0];
  });

  ipcMain.handle('store:get', (_, { key }) => store.get(key));
  ipcMain.handle('store:set', (_, { key, value }) => {
    store.set(key, value);
  });
}
```

### Example 3: Renderer Integration Choices

React hook:

```typescript
// renderer/src/hooks/useIPC.ts
import { useEffect, useState } from 'react';

export function useAppVersion() {
  const [version, setVersion] = useState<string | null>(null);

  useEffect(() => {
    window.electron.invoke('app:get-version', undefined).then(setVersion);
  }, []);

  return version;
}
```

Vue composable:

```typescript
// renderer/src/composables/useAppVersion.ts
import { onMounted, ref } from 'vue';

export function useAppVersion() {
  const version = ref<string | null>(null);

  onMounted(async () => {
    version.value = await window.electron.invoke('app:get-version', undefined);
  });

  return { version };
}
```

SvelteKit runes module:

```typescript
// renderer/src/lib/electron/ipc.svelte.ts
export function createVersionQuery() {
  const state = $state({ value: null as string | null, loading: false });

  const run = async () => {
    state.loading = true;
    state.value = await window.electron.invoke('app:get-version', undefined);
    state.loading = false;
  };

  return { state, run };
}
```

### Example 4: Auto-Updater Setup

```typescript
// main/services/updater.ts
import { autoUpdater } from 'electron-updater';
import log from 'electron-log';
import type { BrowserWindow } from 'electron';

export function setupAutoUpdater(mainWindow: BrowserWindow) {
  autoUpdater.logger = log;
  autoUpdater.autoDownload = false;
  autoUpdater.autoInstallOnAppQuit = true;

  autoUpdater.on('checking-for-update', () => mainWindow.webContents.send('updater:checking'));
  autoUpdater.on('update-available', (info) => mainWindow.webContents.send('updater:available', info));
  autoUpdater.on('update-not-available', () => mainWindow.webContents.send('updater:not-available'));
  autoUpdater.on('download-progress', (progress) => mainWindow.webContents.send('updater:progress', progress));
  autoUpdater.on('update-downloaded', () => mainWindow.webContents.send('updater:downloaded'));
  autoUpdater.on('error', (error) => mainWindow.webContents.send('updater:error', error.message));

  setTimeout(() => {
    autoUpdater.checkForUpdates();
  }, 5000);
}
```

### Example 5: Native Menu Setup

```typescript
// main/menu.ts
import { app, BrowserWindow, Menu, shell } from 'electron';

export function createMenu(mainWindow: BrowserWindow) {
  const isMac = process.platform === 'darwin';

  const template: Electron.MenuItemConstructorOptions[] = [
    ...(isMac
      ? [{ label: app.name, submenu: [{ role: 'about' }, { type: 'separator' }, { role: 'quit' }] }]
      : []),
    {
      label: 'File',
      submenu: [
        {
          label: 'Open File',
          accelerator: 'CmdOrCtrl+O',
          click: () => mainWindow.webContents.send('menu:open-file')
        },
        { type: 'separator' },
        isMac ? { role: 'close' } : { role: 'quit' }
      ]
    },
    {
      label: 'Help',
      submenu: [{ label: 'Documentation', click: () => shell.openExternal('https://www.electronjs.org/docs/latest') }]
    }
  ];

  Menu.setApplicationMenu(Menu.buildFromTemplate(template));
}
```

## Anti-Patterns

### Do not enable nodeIntegration

```typescript
// BAD
const win = new BrowserWindow({
  webPreferences: {
    nodeIntegration: true,
    contextIsolation: false
  }
});

// GOOD
const winSafe = new BrowserWindow({
  webPreferences: {
    preload: path.join(__dirname, 'preload.js'),
    contextIsolation: true,
    nodeIntegration: false,
    sandbox: true
  }
});
```

### Do not use deprecated remote module

```typescript
// BAD
const { BrowserWindow } = require('@electron/remote');

// GOOD
const path = await window.electron.invoke('dialog:open-file', {});
```

### Do not expose raw ipcRenderer to renderer

```typescript
// BAD
contextBridge.exposeInMainWorld('electron', { ipcRenderer });

// GOOD
contextBridge.exposeInMainWorld('electron', {
  invoke: (channel: string, data: unknown) => {
    const allowedChannels = ['app:get-version', 'file:read'];
    if (!allowedChannels.includes(channel)) {
      throw new Error(`Channel ${channel} not allowed`);
    }
    return ipcRenderer.invoke(channel, data);
  }
});
```

## Quick Reference

| Task | Pattern |
|------|---------|
| Create project | `npm create electron-vite@latest` |
| Main process file access | Use Node.js `fs` module in main |
| Renderer file access | IPC through preload |
| Persistent storage | `electron-store` in main process |
| Auto-updates | `electron-updater` |
| Native notifications | `new Notification()` in main |
| System tray | `Tray` class in main |
| Keyboard shortcuts | `globalShortcut.register()` |
| Deep linking | `app.setAsDefaultProtocolClient()` |
| Code signing | `electron-builder` config |

## Resources

- [Electron Documentation](https://www.electronjs.org/docs/latest)
- [Electron Forge](https://www.electronforge.io/)
- [electron-vite](https://electron-vite.org/)
- [electron-builder](https://www.electron.build/)
- [Electron Security Checklist](https://www.electronjs.org/docs/latest/tutorial/security)
