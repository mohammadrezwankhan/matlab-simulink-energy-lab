#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../.."
export COREPACK_ENABLE_DOWNLOAD_PROMPT=0
printf "Installing Codex CLI...\n"
npm install --global @openai/codex@0.164.0
codex --version

# Keep generated dependency directories out of local Git status.
exclude_file="$(git rev-parse --git-path info/exclude)"
mkdir -p "$(dirname "$exclude_file")"
touch "$exclude_file"
for pattern in .venv/ node_modules/; do
  grep -qxF "$pattern" "$exclude_file" || printf "%s\n" "$pattern" >> "$exclude_file"
done

printf "\nSetup complete. Sign in with: codex login --device-auth\n"
printf "Then run: codex\n"
