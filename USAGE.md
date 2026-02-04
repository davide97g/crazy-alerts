# crazy-alerts — Usage reference for LLMs

**crazy-alerts** is a macOS-only CLI that shows overlay alerts from the terminal (20 commands). Overlays are native Swift; they work during screen sharing. Requires Node.js ≥14 and Swift (Xcode / Xcode Command Line Tools).

---

## Install

```bash
npm install -g crazy-alerts
```

After install, all commands (e.g. `ambulance`, `confetti`, `siren`, `checkmark`, `countdown`, `fire`, `klaxon`, `danger`, `strobe`, `rocket`, `clap`, `rainbow`, `banner`, `pill`, `dnd`, `pomodoro`, `reminder`, `typewriter`, `matrix`, `explosion`) are available globally.

---

## Command: `ambulance`

Shows a moving ambulance (🚑) and a message at the bottom of the screen.

**Invocation:**

```bash
ambulance [message]
```

- **`message`** (optional): First positional argument. Default: `"Test CNT-T5431 failed"`.

**Environment variables** (optional; override defaults):

| Variable | Default | Description |
|----------|---------|-------------|
| `AMBULANCE_MESSAGE` | (same as positional message or default above) | Text shown next to the ambulance. |
| `AMBULANCE_DURATION` | `14` | How long the overlay stays (seconds). |
| `AMBULANCE_FONT_SIZE` | `20` | Font size of the message. |
| `AMBULANCE_BORDER_INSET` | `12` | Border/inset (pixels). |
| `AMBULANCE_ASSETS_DIR` | `./assets` (or project `assets/` when run via script) | Folder for `alert.gif` (siren) and optional `alarm.wav`. |

**Assets:** Place `alert.gif` (siren) in the `assets/` folder at the project root. An alarm sound plays for the duration: add `alarm.wav` in `assets/` for a custom siren; otherwise the system “Glass” sound is used.

**Examples:**

```bash
ambulance "Test failed"
ambulance "Build failed"
AMBULANCE_MESSAGE="Deploy done" ambulance
AMBULANCE_DURATION=20 ambulance "Release shipped"
```

---

## Command: `confetti`

Full-screen confetti animation on all displays.

**Invocation:**

```bash
confetti [options]
```

**Inline options** (override env and defaults; use `--key=value` or `--key value`):

| Flag | Short | Env equivalent | Default | Description |
|------|-------|-----------------|---------|-------------|
| `--particle-count` | `-c` | `CONFETTI_PARTICLE_COUNT` | `300` | Total particles. |
| `--duration` | `-d` | `CONFETTI_DURATION` | `6` | Seconds before auto-close. |
| `--gravity` | `-g` | `CONFETTI_GRAVITY` | `0.5` | Fall speed (higher = faster). |
| `--velocity` | `-v` | `CONFETTI_VELOCITY` | `20` | Initial burst strength. |
| `--size-min` | — | `CONFETTI_SIZE_MIN` | `10` | Min particle size. |
| `--size-max` | — | `CONFETTI_SIZE_MAX` | `50` | Max particle size. |
| `--spawn-rate` | `-r` | `CONFETTI_SPAWN_RATE` | `70` | Particles per burst. |

**Environment variables** (optional; overridden by inline flags):

Same as above, plus `CONFETTI_ASSETS_DIR` (default: project `assets/` when run via script). A success sound plays once at start: add `success.wav` in `assets/` for a custom sound; otherwise the system “Hero” sound is used.

**Precedence:** inline args > environment > defaults.

**Examples:**

```bash
confetti
confetti --particle-count=500 --duration=10
confetti -c 500 -d 8 --gravity=0.3
confetti --size-min=8 --size-max=40
CONFETTI_PARTICLE_COUNT=500 confetti
confetti --duration=12 -r 100
```

---

## Platform and requirements

- **OS:** macOS (Darwin) only. On other platforms the scripts exit with an error.
- **Node.js:** ≥14.
- **Swift:** Must be installed (Xcode or Xcode Command Line Tools).

---

## Command: `siren`

Full-screen red pulsing alert with optional message and looping alarm.

**Invocation:** `siren [message]`

**Env:** `SIREN_MESSAGE`, `SIREN_DURATION` (default 10), `SIREN_FONT_SIZE`, `SIREN_ASSETS_DIR`. Uses `assets/alarm.wav` or system "Glass".

---

## Command: `checkmark`

Big green checkmark with optional message and success sound.

**Invocation:** `checkmark [message]`

**Env:** `CHECKMARK_MESSAGE`, `CHECKMARK_DURATION` (default 4), `CHECKMARK_FONT_SIZE`, `CHECKMARK_ASSETS_DIR`. Success: `assets/success.wav` or "Hero".

---

## Command: `countdown`

Full-screen countdown (e.g. 5, 4, 3, 2, 1, Go!).

**Invocation:** `countdown [start] [message]` — if first arg is a number it's the start value; optional second arg is message. Or `countdown "message"` (start=5).

**Env:** `COUNTDOWN_START` (default 5), `COUNTDOWN_MESSAGE`, `COUNTDOWN_DURATION_AFTER_ZERO`, `COUNTDOWN_SOUND_AT_ZERO`, `COUNTDOWN_FONT_SIZE`, `COUNTDOWN_ASSETS_DIR`.

---

## Command: `fire`

Full-screen flame effect with message.

**Invocation:** `fire [message]`

**Env:** `FIRE_MESSAGE`, `FIRE_DURATION` (default 8), `FIRE_PARTICLE_COUNT`, `FIRE_FONT_SIZE`, `FIRE_ASSETS_DIR`.

---

## Command: `klaxon`

Red/black full-screen flash with short repeating beeps. **Invocation:** `klaxon [message]`. **Env:** `KLAXON_MESSAGE`, `KLAXON_DURATION` (6), `KLAXON_FONT_SIZE`, `KLAXON_ASSETS_DIR`.

---

## Command: `danger`

Dark overlay, ⚠️ or 💀 (env `DANGER_ICON`), message, looping alarm. **Invocation:** `danger [message]`. **Env:** `DANGER_MESSAGE`, `DANGER_DURATION` (8), `DANGER_FONT_SIZE`, `DANGER_ICON`, `DANGER_ASSETS_DIR`.

---

## Command: `strobe`

White/red alternating full-screen flash. **Invocation:** `strobe [message]`. **Env:** `STROBE_MESSAGE`, `STROBE_DURATION` (5), `STROBE_FONT_SIZE`.

---

## Command: `rocket`

🚀 moving up, message, success sound. **Invocation:** `rocket [message]`. **Env:** `ROCKET_MESSAGE`, `ROCKET_DURATION` (5), `ROCKET_FONT_SIZE`, `ROCKET_ASSETS_DIR`.

---

## Command: `clap`

👏 and message, success sound. **Invocation:** `clap [message]`. **Env:** `CLAP_MESSAGE`, `CLAP_DURATION` (4), `CLAP_FONT_SIZE`, `CLAP_ASSETS_DIR`.

---

## Command: `rainbow`

Slow rainbow gradient + message. **Invocation:** `rainbow [message]`. **Env:** `RAINBOW_MESSAGE`, `RAINBOW_DURATION` (6), `RAINBOW_FONT_SIZE`.

---

## Command: `banner`

Scrolling ticker at top or bottom. **Invocation:** `banner [message]`. **Env:** `BANNER_MESSAGE`, `BANNER_DURATION` (10), `BANNER_SPEED`, `BANNER_POSITION` (top/bottom), `BANNER_FONT_SIZE`.

---

## Command: `pill`

Small centered pill badge. **Invocation:** `pill [message]`. **Env:** `PILL_MESSAGE`, `PILL_DURATION` (5), `PILL_FONT_SIZE`.

---

## Command: `dnd`

Dim overlay + “Do not disturb” (or custom message). Stays until process exits if `DND_DURATION`=0. **Invocation:** `dnd [message]`. **Env:** `DND_MESSAGE`, `DND_DURATION`, `DND_FONT_SIZE`.

---

## Command: `pomodoro`

“Time for a break” + ☕, gentle sound. **Invocation:** `pomodoro [message]`. **Env:** `POMODORO_MESSAGE`, `POMODORO_DURATION` (8), `POMODORO_FONT_SIZE`, `POMODORO_ASSETS_DIR`.

---

## Command: `reminder`

Big message, optional sound. **Invocation:** `reminder [message]`. **Env:** `REMINDER_MESSAGE`, `REMINDER_DURATION` (6), `REMINDER_FONT_SIZE`, `REMINDER_ASSETS_DIR`.

---

## Command: `typewriter`

Message types out with blinking cursor; beep at end. **Invocation:** `typewriter [message]`. **Env:** `TYPEWRITER_MESSAGE`, `TYPEWRITER_DURATION` (hold after done), `TYPEWRITER_CHAR_DELAY`, `TYPEWRITER_FONT_SIZE`, `TYPEWRITER_ASSETS_DIR`.

---

## Command: `matrix`

Falling green characters; optional centered message. **Invocation:** `matrix [message]`. **Env:** `MATRIX_MESSAGE`, `MATRIX_DURATION` (8), `MATRIX_FONT_SIZE`, `MATRIX_COLUMNS`.

---

## Command: `explosion`

Single particle burst from center; optional message. **Invocation:** `explosion [message]`. **Env:** `EXPLOSION_MESSAGE`, `EXPLOSION_DURATION` (4), `EXPLOSION_PARTICLE_COUNT`, `EXPLOSION_FONT_SIZE`.

---

## Running without global install

From the project directory:

```bash
node scripts/ambulance-run.js "Your message"
node scripts/confetti-run.js --duration=8
node scripts/siren-run.js "Alert"
node scripts/checkmark-run.js "Done"
node scripts/countdown-run.js 5 "Launch"
node scripts/fire-run.js "Deploy failed"
node scripts/klaxon-run.js "Stop!"
node scripts/banner-run.js "Build in progress..."
node scripts/typewriter-run.js "Done."
npm run ambulance -- "Your message"
npm run confetti -- --particle-count=400
```

---

## Summary for LLMs

All commands take optional `[message]` (or command-specific args) and env vars `*_MESSAGE`, `*_DURATION`, `*_FONT_SIZE`, etc. **Commands:** ambulance, confetti, siren, checkmark, countdown, fire, klaxon, danger, strobe, rocket, clap, rainbow, banner, pill, dnd, pomodoro, reminder, typewriter, matrix, explosion. macOS only; Node ≥14; Swift required.
