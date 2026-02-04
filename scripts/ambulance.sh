#!/bin/bash

# =============================================================================
# 🚑 AMBULANCE ANIMATION SCRIPT
# =============================================================================
# Displays 🚑 + red message + 🚨 moving right-to-left at the bottom of the screen.
# Same overlay style as confetti. No image required.
#
# Usage: ./scripts/ambulance.sh
#        ./scripts/ambulance.sh "Test CNT-T5431 failed"
#        AMBULANCE_MESSAGE="Build failed" ./scripts/ambulance.sh
# From anywhere (npx): npx connect-e2e-test-automation "Test failed"
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SWIFT_FILE="$SCRIPT_DIR/ambulance.swift"

# Assets (siren GIF, optional alarm.wav) - so script works from any CWD
export AMBULANCE_ASSETS_DIR="${AMBULANCE_ASSETS_DIR:-$PROJECT_ROOT/assets}"

# Message: first argument, or env, or default (🚨 is added at the end by the script)
export AMBULANCE_MESSAGE="${AMBULANCE_MESSAGE:-${1:-Test CNT-T5431 failedddddddddddd 🙊}}"

# Optional: duration (seconds), font size (pt), border inset (pt)
export AMBULANCE_DURATION="${AMBULANCE_DURATION:-14}"
export AMBULANCE_FONT_SIZE="${AMBULANCE_FONT_SIZE:-20}"
export AMBULANCE_BORDER_INSET="${AMBULANCE_BORDER_INSET:-12}"

if [[ "$(uname)" != "Darwin" ]]; then
    echo "❌ This script only works on macOS"
    exit 1
fi

swift "$SWIFT_FILE" 2>/dev/null &

echo "🚑 Ambulance animation launched! Message: $AMBULANCE_MESSAGE 🚨"
