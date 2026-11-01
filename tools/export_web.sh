#!/usr/bin/env bash
set -euo pipefail
project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ ! -f "$project_root/export_presets.cfg" ]]; then
  cp "$project_root/tools/web_export_presets.cfg" "$project_root/export_presets.cfg"
fi
mkdir -p "$project_root/exports/web"
exec godot --headless --path "$project_root" --export-release Web
