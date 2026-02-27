#!/usr/bin/env bash
set -euo pipefail

THEME_NAME="BRUTAL 2026"
SHELL_THEME_FILE="$HOME/.config/shell/terminal-brutal-2026.sh"
GTK3_CSS="$HOME/.config/gtk-3.0/gtk.css"
GTK4_CSS="$HOME/.config/gtk-4.0/gtk.css"
KONSOLE_DIR="$HOME/.local/share/konsole"
KONSOLE_PROFILE="$KONSOLE_DIR/Brutal2026.profile"
KONSOLE_SCHEME="$KONSOLE_DIR/Brutal2026.colorscheme"
KONSOLERC="$HOME/.config/konsolerc"

log() {
  printf '[%s] %s\n' "$THEME_NAME" "$1"
}

ensure_parent() {
  mkdir -p "$(dirname "$1")"
}

ensure_source_line() {
  local rc_file="$1"
  local source_line='[ -r "$HOME/.config/shell/terminal-brutal-2026.sh" ] && . "$HOME/.config/shell/terminal-brutal-2026.sh"'

  [ -f "$rc_file" ] || touch "$rc_file"
  if ! grep -Fq "$source_line" "$rc_file"; then
    {
      printf '\n# Global terminal look: BRUTAL 2026\n'
      printf '%s\n' "$source_line"
    } >> "$rc_file"
    log "Добавлено подключение темы в $rc_file"
  else
    log "Подключение темы уже есть в $rc_file"
  fi
}

append_css_block() {
  local css_file="$1"
  local block_id='BRUTAL 2026 TERMINAL SCROLLBAR'

  ensure_parent "$css_file"
  [ -f "$css_file" ] || touch "$css_file"

  if grep -Fq "$block_id" "$css_file"; then
    log "Блок скроллбара уже есть в $css_file"
    return
  fi

  cat >> "$css_file" <<'CSS'

/* === BRUTAL 2026 TERMINAL SCROLLBAR (BEGIN) === */
window.background.terminal-window scrollbar {
  min-width: 10px;
  min-height: 10px;
}

window.background.terminal-window scrollbar trough {
  background-color: #05070d;
  border: 1px solid #0d1422;
  border-radius: 999px;
}

window.background.terminal-window scrollbar slider {
  background-color: #213249;
  border: 1px solid #2b4b70;
  border-radius: 999px;
  min-width: 9px;
  min-height: 28px;
}

window.background.terminal-window scrollbar slider:hover {
  background-color: #2d4f77;
}

window.background.terminal-window scrollbar slider:active {
  background-color: #3a6aa0;
}
/* === BRUTAL 2026 TERMINAL SCROLLBAR (END) === */
CSS

  log "Добавлен стиль скроллбара в $css_file"
}

install_shell_theme_file() {
  ensure_parent "$SHELL_THEME_FILE"
  cat > "$SHELL_THEME_FILE" <<'SH'
# Global terminal style: BRUTAL 2026
# Source from interactive shells (bash/zsh).

case "$-" in
  *i*) ;;
  *) return 0 ;;
esac

[ -n "${BRUTAL_2026_DISABLED:-}" ] && return 0
[ -n "${BRUTAL_2026_APPLIED:-}" ] && return 0
[ -t 1 ] || return 0

term="${TERM:-}"
case "$term" in
  dumb|linux|vt100) return 0 ;;
esac

__brutal2026_emit_osc() {
  # tmux/screen require wrapped OSC passthrough.
  if [ -n "${TMUX:-}" ]; then
    printf '\033Ptmux;\033\033]%s\007\033\\' "$1"
    return
  fi
  case "$term" in
    screen*|tmux*)
      printf '\033P\033]%s\007\033\\' "$1"
      return
      ;;
  esac
  printf '\033]%s\007' "$1"
}

__brutal2026_emit_osc '10;#8f9db2'  # foreground
__brutal2026_emit_osc '11;#020307'  # background
__brutal2026_emit_osc '12;#5ee2ff'  # cursor
__brutal2026_emit_osc '0;Terminal // BRUTAL 2026'

BRUTAL_2026_APPLIED=1
export BRUTAL_2026_APPLIED

unset -f __brutal2026_emit_osc 2>/dev/null || true
unset term
SH
  log "Обновлен $SHELL_THEME_FILE"
}

apply_to_current_terminal() {
  if [ -t 1 ]; then
    printf '\033]10;#8f9db2\a\033]11;#020307\a\033]12;#5ee2ff\a\033]0;Terminal // BRUTAL 2026\a'
    log "Тема применена к текущему терминалу"
  fi
}

apply_to_live_pts() {
  local tty_dev=""
  while read -r tty_dev; do
    [ -n "$tty_dev" ] || continue
    [ -w "/dev/$tty_dev" ] || continue
    printf '\033]10;#8f9db2\a\033]11;#020307\a\033]12;#5ee2ff\a\033]0;Terminal // BRUTAL 2026\a' > "/dev/$tty_dev" || true
  done < <(ps -u "$(id -un)" -o tty= | awk '$1 ~ /^pts\/[0-9]+$/ {print $1}' | sort -u)

  log "Тема отправлена в активные pts-сессии"
}

setup_gnome_terminal_profile() {
  if ! command -v gsettings >/dev/null 2>&1; then
    log "gsettings не найден, пропускаю настройку gnome-terminal"
    return
  fi

  if ! gsettings list-schemas | grep -q '^org.gnome.Terminal.ProfilesList$'; then
    log "Схема gnome-terminal не найдена, пропускаю"
    return
  fi

  local profile
  profile="$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")"
  local base="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile}/"

  gsettings set "$base" visible-name 'BRUTAL 2026'
  gsettings set "$base" use-theme-colors false
  gsettings set "$base" foreground-color 'rgb(143,157,178)'
  gsettings set "$base" background-color 'rgb(2,3,7)'
  gsettings set "$base" cursor-colors-set true
  gsettings set "$base" cursor-background-color 'rgb(94,226,255)'
  gsettings set "$base" cursor-foreground-color 'rgb(2,3,7)'
  gsettings set "$base" bold-is-bright true
  gsettings set "$base" scrollbar-policy 'always'
  gsettings set "$base" palette "['rgb(32,38,51)', 'rgb(194,94,108)', 'rgb(124,173,130)', 'rgb(194,166,107)', 'rgb(120,165,228)', 'rgb(156,134,209)', 'rgb(94,226,255)', 'rgb(171,184,204)', 'rgb(54,64,86)', 'rgb(226,122,138)', 'rgb(149,203,158)', 'rgb(224,193,128)', 'rgb(144,188,246)', 'rgb(182,161,231)', 'rgb(132,236,255)', 'rgb(203,214,232)']"

  log "Профиль gnome-terminal обновлен"
}

setup_konsole_profile() {
  mkdir -p "$KONSOLE_DIR" "$HOME/.config"

  cat > "$KONSOLE_SCHEME" <<'SCHEME'
[Background]
Color=2,3,7

[BackgroundIntense]
Color=2,3,7

[BackgroundFaint]
Color=2,3,7

[Foreground]
Color=143,157,178

[ForegroundIntense]
Bold=true
Color=173,190,214

[ForegroundFaint]
Color=116,129,149

[Color0]
Color=32,38,51

[Color0Intense]
Color=54,64,86

[Color0Faint]
Color=21,25,33

[Color1]
Color=194,94,108

[Color1Intense]
Color=226,122,138

[Color1Faint]
Color=147,72,82

[Color2]
Color=124,173,130

[Color2Intense]
Color=149,203,158

[Color2Faint]
Color=95,132,99

[Color3]
Color=194,166,107

[Color3Intense]
Color=224,193,128

[Color3Faint]
Color=149,127,82

[Color4]
Color=120,165,228

[Color4Intense]
Color=144,188,246

[Color4Faint]
Color=92,127,176

[Color5]
Color=156,134,209

[Color5Intense]
Color=182,161,231

[Color5Faint]
Color=120,103,161

[Color6]
Color=94,226,255

[Color6Intense]
Color=132,236,255

[Color6Faint]
Color=72,173,195

[Color7]
Color=171,184,204

[Color7Intense]
Color=203,214,232

[Color7Faint]
Color=130,140,155

[General]
Description=Brutal 2026
Opacity=1
SCHEME

  cat > "$KONSOLE_PROFILE" <<'PROFILE'
[Appearance]
ColorScheme=Brutal2026

[General]
Name=Brutal2026
Parent=FALLBACK/

[Scrolling]
ScrollBarPosition=2
HistoryMode=2
HistorySize=10000
PROFILE

  cat > "$KONSOLERC" <<'RC'
[Desktop Entry]
DefaultProfile=Brutal2026.profile
RC

  log "Профиль Konsole обновлен"
}

main() {
  install_shell_theme_file
  ensure_source_line "$HOME/.zshrc"
  ensure_source_line "$HOME/.bashrc"

  append_css_block "$GTK3_CSS"
  append_css_block "$GTK4_CSS"

  setup_gnome_terminal_profile
  setup_konsole_profile

  apply_to_current_terminal
  apply_to_live_pts

  log "Готово. Откройте новое окно терминала для полного применения GTK-скроллбара."
}

main "$@"
