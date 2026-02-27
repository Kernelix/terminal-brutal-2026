#!/usr/bin/env bash
set -euo pipefail

echo "Удаляю BRUTAL 2026 из shell..."
for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
  [ -f "$rc" ] || continue
  tmp="$(mktemp)"
  awk '!/terminal-brutal-2026\.sh/ && !/Global terminal look: BRUTAL 2026/' "$rc" > "$tmp"
  mv "$tmp" "$rc"
  echo "  - очищен $rc"
done

rm -f "$HOME/.config/shell/terminal-brutal-2026.sh"
rm -f "$HOME/.local/share/konsole/Brutal2026.profile" "$HOME/.local/share/konsole/Brutal2026.colorscheme"

echo "Для полного отката gtk.css удалите блок BRUTAL 2026 вручную из:"
echo "  $HOME/.config/gtk-3.0/gtk.css"
echo "  $HOME/.config/gtk-4.0/gtk.css"
