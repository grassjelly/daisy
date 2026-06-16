#!/usr/bin/env bash
# Usage: source setup_tmux.bash
# Sets TMUXINATOR_CONFIG to the absolute path of the profiles directory.

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Error: This script must be sourced, not executed."
    echo "  Usage: source $(basename "${BASH_SOURCE[0]}")"
    exit 1
fi

export TMUXINATOR_CONFIG="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"
echo "TMUXINATOR_CONFIG set to: $TMUXINATOR_CONFIG"

alias mux=tmuxinator
