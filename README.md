# Winbox Home Assistant Addon

This addon runs [Winbox](https://mikrotik.com/download) (MikroTik's official router management GUI) inside Home Assistant using Wine emulation and noVNC for browser access. No need for a Windows machine or separate VNC client!

## Features
- Web-based access to a full desktop (launch Winbox from the menu).
- Auto-discovers MikroTik devices on your LAN.
- Secure VNC password (optional).
- Works on x86/ARM HA installs.

## Installation
1. Add this repo to HA: **Settings > Add-ons > Add-on Store > Repositories** → Add `https://github.com/soulripper13/winbox-addon`.
2. Search for "Winbox" and install.
3. In **Options**, set `vnc_password` (recommended for security).
4. Start the addon.
5. Click **OPEN WEB UI** → You'll see a desktop. Right-click or use the menu (bottom-left) to launch **Winbox**.
6. In Winbox, connect to your router (discovers automatically; enter IP/credentials if needed).

## Configuration
| Option        | Description                  | Default       |
|---------------|------------------------------|---------------|
| `vnc_password` | Password for VNC/noVNC access | None (insecure) |
| `log_level`   | Logging verbosity            | INFO          |

## Usage Tips
- **Auto-connect to router**: Edit `/opt/start-winbox.sh` in the container (via SSH addon) to add `/ip=192.168.88.1` arg: `DISPLAY=:1 wine /opt/winbox64.exe /ip=192.168.88.1`.
- **Performance**: Use on amd64 for best Wine support. On ARM, it may run slower.
- **Troubleshooting**:
  - No discovery? Ensure UDP 5678 is open (MikroTik neighbor port).
  - Wine errors? Check logs (`INFO` level).
  - Update Winbox: Restart addon after manual download to `/opt/winbox64.exe`.
- **Security**: Change VNC password; expose only locally.

## Credits
- Based on [tiredofit/docker-novnc](https://github.com/tiredofit/docker-novnc) for GUI.
- Wine for Windows app emulation.

Issues? Open a GitHub issue or ping @soulripper13.
