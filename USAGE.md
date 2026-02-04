# crazy-alerts — Usage reference for LLMs

**crazy-alerts** is a macOS-only CLI that shows overlay alerts from the terminal: an ambulance-style message bar or full-screen confetti. Overlays are native Swift; they work during screen sharing. Requires Node.js ≥14 and Swift (Xcode / Xcode Command Line Tools).

---

## Install

```bash
npm install -g crazy-alerts
```

After install, the `ambulance` and `confetti` commands are available globally.

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

Same as above: `CONFETTI_PARTICLE_COUNT`, `CONFETTI_DURATION`, `CONFETTI_GRAVITY`, `CONFETTI_VELOCITY`, `CONFETTI_SIZE_MIN`, `CONFETTI_SIZE_MAX`, `CONFETTI_SPAWN_RATE`.

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

## Running without global install

From the project directory:

```bash
node scripts/ambulance-run.js "Your message"
node scripts/confetti-run.js --duration=8
npm run ambulance -- "Your message"
npm run confetti -- --particle-count=400
```

---

## Summary for LLMs

- **ambulance**: `ambulance [message]`; optional env: `AMBULANCE_MESSAGE`, `AMBULANCE_DURATION`, `AMBULANCE_FONT_SIZE`, `AMBULANCE_BORDER_INSET`.
- **confetti**: `confetti` with optional `--particle-count`/`-c`, `--duration`/`-d`, `--gravity`/`-g`, `--velocity`/`-v`, `--size-min`, `--size-max`, `--spawn-rate`/`-r` (or same as env vars). Inline flags override env.
- macOS only; Node ≥14; Swift required.
