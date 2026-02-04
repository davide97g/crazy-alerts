# crazy-alerts

macOS-only CLI: 20 overlay alerts from the terminal. Uses native Swift; works during screen sharing.

## Install

```bash
npm install -g crazy-alerts
```

## Commands

### `ambulance`

Shows a moving ambulance + message at the bottom of the screen, with an animated siren GIF (and a copy in the top-right corner). An alarm sound plays for the duration (system sound or optional `assets/alarm.wav`).

```bash
ambulance "Test failed"
ambulance "Build failed"
# or with env
AMBULANCE_MESSAGE="Deploy done" ambulance
```

Optional env: `AMBULANCE_DURATION`, `AMBULANCE_FONT_SIZE`, `AMBULANCE_BORDER_INSET`, `AMBULANCE_ASSETS_DIR`. Assets (siren GIF, optional alarm) live in `assets/` and are included in the package.

### `confetti`

Full-screen confetti celebration with a success sound (system “Hero” or optional `assets/success.wav`).

```bash
confetti
# inline overrides (override env and defaults)
confetti --particle-count=500 --duration=10
confetti -c 500 -d 8 --gravity=0.3
# or env
CONFETTI_PARTICLE_COUNT=500 CONFETTI_DURATION=10 confetti
```

Optional **inline flags**: `--particle-count` / `-c`, `--duration` / `-d`, `--gravity` / `-g`, `--velocity` / `-v`, `--size-min`, `--size-max`, `--spawn-rate` / `-r`. Optional **env**: same names. Inline args override env.

### `siren`

Full-screen red pulsing alert with optional message and looping alarm sound.

```bash
siren "Server down"
SIREN_DURATION=15 siren "Critical"
```

Optional env: `SIREN_MESSAGE`, `SIREN_DURATION`, `SIREN_FONT_SIZE`, `SIREN_ASSETS_DIR`. Uses `assets/alarm.wav` if present, else system "Glass".

### `checkmark`

Big green checkmark with optional message and success sound.

```bash
checkmark "Build passed"
CHECKMARK_DURATION=6 checkmark "Deploy done"
```

Optional env: `CHECKMARK_MESSAGE`, `CHECKMARK_DURATION`, `CHECKMARK_FONT_SIZE`, `CHECKMARK_ASSETS_DIR`. Success sound: `assets/success.wav` or "Hero".

### `countdown`

Full-screen countdown (e.g. 5, 4, 3, 2, 1, Go!) with optional message and sound at zero.

```bash
countdown
countdown 10
countdown 5 "Launch in..."
```

Optional env: `COUNTDOWN_START`, `COUNTDOWN_MESSAGE`, `COUNTDOWN_DURATION_AFTER_ZERO`, `COUNTDOWN_SOUND_AT_ZERO`, `COUNTDOWN_FONT_SIZE`, `COUNTDOWN_ASSETS_DIR`.

### `fire`

Full-screen flame effect with message (failure / drama alert).

```bash
fire "Deploy failed"
FIRE_DURATION=12 fire "Server down"
```

Optional env: `FIRE_MESSAGE`, `FIRE_DURATION`, `FIRE_PARTICLE_COUNT`, `FIRE_FONT_SIZE`, `FIRE_ASSETS_DIR`.

### More alerts

| Command | Description | Example |
|--------|-------------|--------|
| `klaxon` | Red/black flash + short beeps | `klaxon "Stop!"` |
| `danger` | Dark overlay + ⚠️ (or 💀) + message, alarm | `danger "P0"` |
| `strobe` | White/red alternating flash | `strobe "Alert"` |
| `rocket` | 🚀 moving up + message, success sound | `rocket "Shipped!"` |
| `clap` | 👏 + “Well done”, success sound | `clap` |
| `rainbow` | Slow rainbow gradient + message | `rainbow "All green"` |
| `banner` | Scrolling ticker (top/bottom) | `banner "Build in progress..."` |
| `pill` | Small centered pill badge | `pill "Deploy started"` |
| `dnd` | Dim overlay + “Do not disturb” (stays until killed if duration=0) | `dnd "In a meeting"` |
| `pomodoro` | “Time for a break” + ☕, gentle sound | `pomodoro` |
| `reminder` | Big message only, optional sound | `reminder "Drink water"` |
| `typewriter` | Message types out with cursor, beep at end | `typewriter "Done."` |
| `matrix` | Falling green characters + optional message | `matrix "Build..."` |
| `explosion` | Single burst from center + optional message | `explosion "Merge to main"` |

Each supports env vars (e.g. `*_MESSAGE`, `*_DURATION`, `*_FONT_SIZE`); see USAGE.md.

## Requirements

- **macOS** (Darwin)
- **Node.js** ≥ 14
- **Swift** (included with Xcode / Xcode Command Line Tools)

## License

MIT
