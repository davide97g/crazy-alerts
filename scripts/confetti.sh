#!/bin/bash

# =============================================================================
# 🎉 CONFETTI CELEBRATION SCRIPT
# =============================================================================
# Displays a full-screen confetti explosion animation on macOS.
# Truly transparent overlay - works during screen sharing!
#
# Usage: ./scripts/confetti.sh
#        PARTICLE_COUNT=500 ./scripts/confetti.sh
# =============================================================================

# --------------------------------
# CONFIGURATION (override via env)
# --------------------------------

# Total number of particles to spawn
export CONFETTI_PARTICLE_COUNT="${CONFETTI_PARTICLE_COUNT:-300}"

# Duration in seconds before auto-close
export CONFETTI_DURATION="${CONFETTI_DURATION:-6}"

# Gravity strength (higher = falls faster)
export CONFETTI_GRAVITY="${CONFETTI_GRAVITY:-0.5}"

# Initial burst velocity (higher = more explosive)
export CONFETTI_VELOCITY="${CONFETTI_VELOCITY:-20}"

# Particle size range (min-max)
export CONFETTI_SIZE_MIN="${CONFETTI_SIZE_MIN:-10}"
export CONFETTI_SIZE_MAX="${CONFETTI_SIZE_MAX:-50}"

# Spawn rate per burst
export CONFETTI_SPAWN_RATE="${CONFETTI_SPAWN_RATE:-70}"

# --------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SWIFT_FILE="$SCRIPT_DIR/confetti.swift"

# Check if we're on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "❌ This script only works on macOS"
    exit 1
fi

# Run Swift directly (suppress deprecation warnings)
swift "$SWIFT_FILE" 2>/dev/null &

echo "🎉 Confetti launched!"
