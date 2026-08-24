<p align="right"><a href="README.pt-BR.md">Ler em Português (Brasil)</a></p>

# sober-fps-unlock

Remove the ~240 FPS cap in [Sober](https://sober.vinegarhq.org/) (the Roblox
client for Linux) by locking `FramerateCap` in Sober's settings file with the
filesystem's immutable attribute.

## Why this is needed

Sober's Roblox client keeps overwriting `GlobalBasicSettings_13.xml` (via an
atomic file replace) every time it starts, resetting `FramerateCap` back to
its default — even if you edit the file by hand or `chmod` it read-only,
since an atomic rename doesn't check the permissions of the file it's
replacing. The community FastFlags (`DFIntTaskSchedulerTargetFps`,
`FFlagTaskSchedulerLimitTargetFpsTo240`) that used to work for this on other
platforms currently get silently ignored on Sober.

Making the file **immutable** (`chattr +i`) blocks the replace at the
filesystem level, which the game can't override even with sudo already
holding the file open — it just keeps the value you set.

## Tested on

- **Distro:** Linux Mint 22.3 (Zena)
- **Kernel:** 6.8.0-117-lowlatency
- **Graphical session:** X11, Cinnamon (`X-Cinnamon`)
- **CPU:** Intel Xeon E5-2683 v4
- **GPU:** NVIDIA GeForce RTX 3050 6GB (proprietary driver 595.84)
- **Sober:** 1.7.1 (Flathub, `org.vinegarhq.Sober`, `org.gnome.Platform` runtime)
- **Filesystem:** ext4 (immutable attribute support required)

## Requirements

- Linux with a filesystem that supports the immutable attribute (ext4, most
  common Linux filesystems do)
- `sudo` access
- Sober installed via Flatpak, opened at least once (so the settings file
  exists)

## Usage

```bash
./sober-fps-unlock.sh                # locks FramerateCap at 10000
./sober-fps-unlock.sh --fps 500      # locks at a specific value
./sober-fps-unlock.sh --undo          # unlocks the file (chattr -i)
```

Don't put `sudo` in front of the whole command — the script calls `sudo`
internally only for the `chattr` step. Running the entire script as root
makes it look in root's home directory instead of yours and it won't find
the config file.

You'll need to close and reopen Sober for the change to take effect. Check
your actual FPS in-game with `Shift+F5`.

If you ever want to change the value again, run `--undo` first, edit
normally (or just rerun the script with a new `--fps`), no need to do
anything else.

## Notes

- This edits a local settings file and does not modify Roblox's game code,
  memory, or network traffic. It's the same class of tweak as disabling
  v-sync or editing a graphics config file.
- This affects the Sober *client* globally, not any specific experience —
  it does not touch or bypass anything a game's own developer configured.
- If a future Sober update changes the settings file name/location or how
  it enforces FPS, this script may need to be adjusted.

## License

MIT

---

## Step-by-step installation and usage

1. **Make sure Sober has been opened at least once** (so its settings
   file actually exists). If you've never opened it:
   ```bash
   flatpak install flathub org.vinegarhq.Sober
   flatpak run org.vinegarhq.Sober
   ```
   then close it again.
2. **Clone this repository:**
   ```bash
   git clone https://github.com/ddkznx/sober-fps-unlock.git
   cd sober-fps-unlock
   ```
3. **Make the script executable** (only needed if you downloaded the
   file directly instead of cloning — `git clone` already preserves
   this):
   ```bash
   chmod +x sober-fps-unlock.sh
   ```
4. **Run it** (no `sudo` before the command — the script asks for your
   password itself, only for the one step that needs it):
   ```bash
   ./sober-fps-unlock.sh
   ```
   This locks `FramerateCap` at 10000. To pick a different value:
   ```bash
   ./sober-fps-unlock.sh --fps 500
   ```
5. **Close Sober completely if it was open**, then open it again.
6. **Check your FPS in-game** with `Shift+F5` — it should no longer be
   stuck around 240.
7. **To undo it later** (unlock the file so it behaves like stock
   Sober again):
   ```bash
   ./sober-fps-unlock.sh --undo
   ```
