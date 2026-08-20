#!/usr/bin/env bash
# set-tab-title.sh — set the terminal/multiplexer tab title with a status indicator
#
# Bundles notifications.sh from the dotfiles submodule (via includeChezmoi)
# for multiplexer detection (_NOTIFY_MUX) and DCS passthrough (_notify_emit),
# then adds cross-multiplexer tab/pane title support and the status indicator
# format used by execute-upsert.
#
# Status indicators:
#   ~  in-progress   — story or pipeline is actively running
#   !  blocked       — story or pipeline is blocked, needs human input
#   x  done          — story or pipeline completed successfully
#
# Tab title format: "<indicator> <workflow-slug> <project-slug>"
# Example: "~ skill-src-upsert dotfiles-include"
#
# Usage:
#   ./set-tab-title.sh --status in-progress --workflow skill-src-upsert --project dotfiles-include
#   ./set-tab-title.sh --status blocked --workflow skill-src-upsert --project dotfiles-include
#   ./set-tab-title.sh --status done --workflow skill-src-upsert --project dotfiles-include
#   ./set-tab-title.sh --status in-progress --workflow skill-src-upsert --project dotfiles-include --story 04-002-add-jwt
#   ./set-tab-title.sh "~ skill-src-upsert dotfiles-include"  # raw title passthrough
#
# Sourcing: can also be sourced to get the set_tab_title function:
#   source ./set-tab-title.sh
#   set_tab_title "~" "skill-src-upsert" "dotfiles-include"

set -euo pipefail

# ─────────────────────────────────────────────────────────────────────
# Inline notifications.sh from the dotfiles submodule.
# This provides _NOTIFY_MUX detection and _notify_emit() for DCS
# passthrough. We extend _NOTIFY_MUX with cmux detection below.
# ─────────────────────────────────────────────────────────────────────
#!/usr/bin/env sh
# shellcheck shell=sh

# =====================================================================
# Terminal Desktop Notifications
# Purpose:
#   - Send desktop notifications from shell scripts via terminal escape
#     sequences (OSC 99 / OSC 777 / OSC 9) or the cmux CLI.
#   - Auto-detect the best available mechanism with a single `notify`
#     entry point.
#   - Auto-wrap OSC sequences in DCS passthrough when inside tmux or
#     GNU screen so notifications reach the outer terminal.
# Shell Support: bash, zsh, sh (POSIX-compliant)
# Chezmoi: Managed by chezmoi, safe to source multiple times
# Security: No external calls (except cmux CLI when explicitly used)
# Multiplexer Support:
#   zellij   - Native forwarding (allow_osc_passthrough=true default)
#   herdr    - Native forwarding (detects outer terminal)
#   tmux     - DCS passthrough (requires 3.3+ + allow-passthrough on)
#   screen   - DCS passthrough (standard)
#   byobu    - Inherits from tmux/screen (same passthrough requirement)
# Protocols:
#   OSC 99  - kitty/otty rich protocol (title + body, urgency, IDs)
#   OSC 777 - rxvt-style simple protocol (title + body)
#   OSC 9   - iTerm2 / simple body-only protocol
#   cmux    - cmux notify CLI (when available)
# References:
#   https://sw.kovidgoyal.net/kitty/desktop-notifications/
#   https://docs.otty.sh/vt/osc/osc-99
#   https://cmux.com/docs/notifications
#   https://github.com/tmux/tmux/wiki/FAQ#passthrough
# =====================================================================

# Guard against re-sourcing
if [ -n "${_DOTFILES_NOTIFICATIONS_SOURCED:-}" ]; then
  return 0 2>/dev/null || exit 0
fi
_DOTFILES_NOTIFICATIONS_SOURCED=1

# ---------------------------------------------------------------------
# Multiplexer detection and DCS passthrough wrapping
#
# tmux and GNU screen swallow unknown OSC sequences instead of
# forwarding them to the outer terminal. To get notifications through,
# the OSC sequence must be wrapped in a DCS (Device Control String)
# passthrough envelope:
#
#   tmux:   \ePtmux;\e\e]<OSC payload>\a\e\\     (double the ESC)
#   screen: \eP\e]<OSC payload>\a\e\\             (single ESC prefix)
#
# zellij and herdr forward OSC sequences natively, so no wrapping is
# needed. byobu inherits from tmux or screen, so it's handled by the
# tmux/screen detection.
#
# Requirements:
#   tmux 3.3+ with `set -g allow-passthrough on` in ~/.tmux.conf
#   GNU screen with DCS passthrough (standard)
# ---------------------------------------------------------------------

# Detect the active multiplexer (cached at source time)
_NOTIFY_MUX="none"
if [ -n "${TMUX:-}" ]; then
  _NOTIFY_MUX="tmux"
elif [ -n "${STY:-}" ]; then
  _NOTIFY_MUX="screen"
elif [ -n "${ZELLIJ:-}" ] || [ -n "${ZELLIJ_SESSION_NAME:-}" ]; then
  _NOTIFY_MUX="zellij"
elif [ -n "${HERDR_SESSION:-}" ] || [ -n "${HERDR_SOCKET:-}" ]; then
  _NOTIFY_MUX="herdr"
fi

# _notify_emit — print an OSC escape sequence, wrapped in DCS
# passthrough if running inside tmux or GNU screen.
#
# Usage: _notify_emit '<OSC sequence>'
# The OSC sequence should already be complete (including terminator).
# For tmux, every ESC inside the payload is doubled.
_notify_emit() {
  local seq="$1"
  case "$_NOTIFY_MUX" in
  tmux)
    # DCS passthrough: \ePtmux;\e\e<seq with ESC doubled>\e\\
    # Double every ESC (\e / \033) in the sequence
    local doubled
    doubled="$(printf '%s' "$seq" | sed 's/\x1b/\x1b\x1b/g')"
    printf '\ePtmux;%s\e\\' "$doubled"
    ;;
  screen)
    # DCS passthrough: \eP<seq>\e\\
    printf '\eP%s\e\\' "$seq"
    ;;
  *)
    # No multiplexer, or zellij/herdr (forward natively)
    printf '%s' "$seq"
    ;;
  esac
}

# ---------------------------------------------------------------------
# OSC 777 — RXVT-style simple notification (title + body)
# Format: ESC ] 777 ; notify ; <title> ; <body> BEL
# Supported by: rxvt-unicode, st, foot, and many others.
# ---------------------------------------------------------------------
notify_osc777() {
  if [ "$#" -lt 1 ]; then
    echo "Usage: notify_osc777 <title> [body]" >&2
    return 2
  fi
  local title="$1"
  local body="${2:-}"
  # Note: OSC 777 has no standard escaping for semicolons in the
  # payload. Titles/bodies containing ';' may be truncated by the
  # terminal parser. Use notify_osc99 (base64 via e=1) if this matters.
  _notify_emit "$(printf '\e]777;notify;%s;%s\a' "$title" "$body")"
}

# ---------------------------------------------------------------------
# OSC 99 — kitty/otty rich notification protocol
# Format: ESC ] 99 ; <metadata> ; <payload> ESC \
# Metadata is colon-separated key=value pairs:
#   i=<id>    notification identifier (for replacement/chunking)
#   d=<0|1>   0 = more chunks follow, 1 = final (default 1)
#   p=<type>  payload type: title, body, ? (capability query)
#   u=<0|1|2> urgency: 0=low, 1=normal (default), 2=critical
#   e=<0|1>   1 = payload is base64-encoded (default 0)
# Note: The kitty spec defines only `title` and `body` payload types.
#       For subtitle support, use notify_cmux_osc99 (cmux extension).
# ---------------------------------------------------------------------
notify_osc99() {
  if [ "$#" -lt 1 ]; then
    echo "Usage: notify_osc99 <title> [body] [id] [urgency]" >&2
    return 2
  fi
  local title="$1"
  local body="${2:-}"
  local id="${3:-1}"
  local urgency="${4:-1}"
  local seq=""

  # Title chunk (d=0: more chunks follow)
  seq="$(printf '\e]99;i=%s:d=0:p=title;%s\e\\' "$id" "$title")"
  # Body chunk (d=1: final chunk, triggers display)
  if [ -n "$body" ]; then
    seq="${seq}$(printf '\e]99;i=%s:d=1:u=%s:p=body;%s\e\\' "$id" "$urgency" "$body")"
  else
    # No body — mark title as final so it displays
    seq="${seq}$(printf '\e]99;i=%s:d=1:u=%s:p=title;%s\e\\' "$id" "$urgency" "$title")"
  fi
  _notify_emit "$seq"
}

# ---------------------------------------------------------------------
# notify_cmux_osc99 — cmux-extended OSC 99 with subtitle support
#
# cmux extends the kitty OSC 99 protocol with a `p=subtitle` payload
# type. The cmux docs also use a slightly different metadata format
# (semicolon-separated key=value pairs with `:` before the payload,
# and `e=1` base64 flag). This wrapper follows the cmux-documented
# format so subtitle renders correctly in cmux.
#
# Format (per cmux docs):
#   ESC ] 99 ; i=<id> ; e=1 ; d=0 ; p=title:<title> ESC \
#   ESC ] 99 ; i=<id> ; e=1 ; d=0 ; p=subtitle:<subtitle> ESC \
#   ESC ] 99 ; i=<id> ; e=1 ; d=1 ; p=body:<body> ESC \
#
# Usage: notify_cmux_osc99 <title> [body] [subtitle] [id]
# References:
#   https://cmux.com/docs/notifications
# ---------------------------------------------------------------------
notify_cmux_osc99() {
  if [ "$#" -lt 1 ]; then
    echo "Usage: notify_cmux_osc99 <title> [body] [subtitle] [id]" >&2
    return 2
  fi
  local title="$1"
  local body="${2:-}"
  local subtitle="${3:-}"
  local id="${4:-1}"
  local seq=""

  # Title chunk (d=0: more chunks follow)
  seq="$(printf '\e]99;i=%s;e=1;d=0;p=title:%s\e\\' "$id" "$title")"
  # Subtitle chunk (cmux extension, d=0: more chunks follow)
  if [ -n "$subtitle" ]; then
    seq="${seq}$(printf '\e]99;i=%s;e=1;d=0;p=subtitle:%s\e\\' "$id" "$subtitle")"
  fi
  # Body chunk (d=1: final chunk, triggers display)
  if [ -n "$body" ]; then
    seq="${seq}$(printf '\e]99;i=%s;e=1;d=1;p=body:%s\e\\' "$id" "$body")"
  else
    # No body — mark title as final so it displays
    seq="${seq}$(printf '\e]99;i=%s;e=1;d=1;p=title:%s\e\\' "$id" "$title")"
  fi
  _notify_emit "$seq"
}

# ---------------------------------------------------------------------
# OSC 9 — iTerm2 / simple body-only notification
# Format: ESC ] 9 ; <message> ESC \
# Supported by: iTerm2, Windows Terminal, and others.
# ---------------------------------------------------------------------
notify_osc9() {
  if [ "$#" -lt 1 ]; then
    echo "Usage: notify_osc9 <message>" >&2
    return 2
  fi
  local message="$1"
  _notify_emit "$(printf '\e]9;%s\e\\' "$message")"
}

# ---------------------------------------------------------------------
# cmux CLI notification (when cmux is available)
# ---------------------------------------------------------------------
_notify_cmux() {
  if [ "$#" -lt 1 ]; then
    echo "Usage: _notify_cmux <title> [body] [subtitle]" >&2
    return 2
  fi
  local title="$1"
  local body="${2:-}"
  local subtitle="${3:-}"

  if [ -n "$subtitle" ]; then
    cmux notify --title "$title" --subtitle "$subtitle" --body "$body"
  elif [ -n "$body" ]; then
    cmux notify --title "$title" --body "$body"
  else
    cmux notify --title "$title"
  fi
}

# ---------------------------------------------------------------------
# notify — high-level dispatcher
# Picks the best available notification mechanism in priority order:
#   1. cmux notify CLI (richest, when available)
#   2. cmux OSC 99 extension (subtitle support, when cmux is running)
#   3. OSC 99 (kitty/otty — title + body)
#   4. OSC 777 (rxvt-style — title + body)
#   5. OSC 9 (iTerm2 — body only, title prepended)
# Override the auto-detection by setting NOTIFY_METHOD to one of:
#   cmux, cmux-osc99, osc99, osc777, osc9
# ---------------------------------------------------------------------
notify() {
  if [ "$#" -lt 1 ]; then
    echo "Usage: notify <title> [body] [subtitle]" >&2
    return 2
  fi
  local title="$1"
  local body="${2:-}"
  local subtitle="${3:-}"
  local method="${NOTIFY_METHOD:-auto}"

  case "$method" in
  cmux)
    if command -v cmux >/dev/null 2>&1; then
      _notify_cmux "$title" "$body" "$subtitle"
    else
      echo "notify: cmux not found" >&2
      return 1
    fi
    ;;
  cmux-osc99)
    notify_cmux_osc99 "$title" "$body" "$subtitle"
    ;;
  osc99)
    notify_osc99 "$title" "$body"
    ;;
  osc777)
    notify_osc777 "$title" "$body"
    ;;
  osc9)
    if [ -n "$body" ]; then
      notify_osc9 "$title: $body"
    else
      notify_osc9 "$title"
    fi
    ;;
  auto)
    if command -v cmux >/dev/null 2>&1; then
      _notify_cmux "$title" "$body" "$subtitle"
    elif [ -n "${CMUX_WORKSPACE_ID:-}${CMUX_SURFACE_ID:-}" ]; then
      # Running inside cmux but no CLI — use cmux OSC 99 extension
      notify_cmux_osc99 "$title" "$body" "$subtitle"
    else
      # Fall back to OSC 99 (works in kitty/otty, harmless in
      # terminals that ignore unknown OSC sequences)
      notify_osc99 "$title" "$body"
    fi
    ;;
  *)
    echo "notify: unknown method '$method' (set NOTIFY_METHOD to cmux, cmux-osc99, osc99, osc777, osc9, or auto)" >&2
    return 2
    ;;
  esac
}

# ---------------------------------------------------------------------
# notify_probe — emit one notification per protocol so you can see
# which ones your current terminal actually renders.
#
# Each notification is labelled with its protocol name in both the
# title and body, so if only one shows up you immediately know which
# method works here. Useful when auto-detection can't tell you the
# answer (terminals don't advertise their OSC support) and you don't
# want to invoke each function one at a time.
#
# Usage: notify_probe [delay_seconds]
#   delay_seconds — seconds to wait between notifications (default 1)
#                   so they don't stack on top of each other.
# ---------------------------------------------------------------------
notify_probe() {
  local delay="${1:-1}"
  local count=0

  printf 'Sending test notifications via each protocol...\n' >&2
  printf 'Detected multiplexer: %s\n' "$_NOTIFY_MUX" >&2
  case "$_NOTIFY_MUX" in
  tmux)
    printf '  (tmux DCS passthrough active — requires allow-passthrough on)\n' >&2
    ;;
  screen)
    printf '  (GNU screen DCS passthrough active)\n' >&2
    ;;
  zellij)
    printf '  (zellij forwards OSC natively)\n' >&2
    ;;
  herdr)
    printf '  (herdr forwards OSC natively)\n' >&2
    ;;
  none)
    printf '  (no multiplexer detected — direct OSC)\n' >&2
    ;;
  esac

  # OSC 9 — body only
  notify_osc9 "OSC 9 test" "If you see this, OSC 9 (iTerm2) works"
  count=$((count + 1))

  # OSC 777 — title + body
  if [ "$delay" -gt 0 ] 2>/dev/null && command -v sleep >/dev/null 2>&1; then
    sleep "$delay"
  fi
  notify_osc777 "OSC 777 test" "If you see this, OSC 777 (rxvt) works"
  count=$((count + 1))

  # OSC 99 — title + body (kitty/otty standard)
  if [ "$delay" -gt 0 ] 2>/dev/null && command -v sleep >/dev/null 2>&1; then
    sleep "$delay"
  fi
  notify_osc99 "OSC 99 test" "If you see this, OSC 99 (kitty/otty) works"
  count=$((count + 1))

  # cmux OSC 99 extension — title + subtitle + body
  if [ "$delay" -gt 0 ] 2>/dev/null && command -v sleep >/dev/null 2>&1; then
    sleep "$delay"
  fi
  notify_cmux_osc99 "cmux OSC 99 test" "If you see this with a subtitle, cmux OSC 99 extension works" "probe"
  count=$((count + 1))

  # cmux CLI (if available)
  if command -v cmux >/dev/null 2>&1; then
    if [ "$delay" -gt 0 ] 2>/dev/null && command -v sleep >/dev/null 2>&1; then
      sleep "$delay"
    fi
    _notify_cmux "cmux CLI test" "If you see this, cmux notify CLI works" "probe"
    count=$((count + 1))
  else
    printf '(cmux CLI not installed — skipped)\n' >&2
  fi

  printf 'Sent %d test notification(s). Check which one(s) appeared.\n' "$count" >&2
  printf 'Set NOTIFY_METHOD to the protocol that worked, e.g.:\n' >&2
  printf '  export NOTIFY_METHOD=osc777\n' >&2
  printf '  export NOTIFY_METHOD=cmux-osc99   # for cmux subtitle support\n' >&2
}

# ---------------------------------------------------------------------
# Protocol comparison (reference)
# ---------------------------------------------------------------------
# Feature              OSC 99   cmux OSC 99  OSC 777   OSC 9   cmux CLI
# Title + body         Yes      Yes          Yes       No      Yes
# Subtitle             No       Yes          No        No      Yes
# Notification ID      Yes      Yes          No        No      No
# Urgency levels       Yes      No           No        No      No
# Chunked payloads     Yes      Yes          No        No      No
# Complexity           Higher   Higher       Lower     Lowest  N/A (CLI)
#
# Multiplexer support (all protocols wrapped in DCS passthrough as needed):
# Multiplexer   Support     Mechanism
# zellij        Native      Forwards OSC 9/777/99 automatically
# herdr         Native      Detects outer terminal, sends appropriate OSC
# tmux          Passthrough DCS wrap (needs 3.3+ + allow-passthrough on)
# screen        Passthrough DCS wrap (standard)
# byobu         Inherited   Wraps tmux or screen (same passthrough)
#
# Use OSC 777 for simple title+body notifications.
# Use OSC 99 when you need IDs, urgency, or chunked payloads (kitty/otty).
# Use cmux OSC 99 when you need subtitle and are running inside cmux.
# Use OSC 9 for body-only notifications (iTerm2/Windows Terminal).
# Use cmux notify CLI when cmux is available (richest, supports subtitle).
# Use `notify` (auto) for the easiest integration — it picks the best
# available method: cmux CLI → cmux OSC 99 → standard OSC 99.
# Use `notify_probe` to discover which protocols your terminal supports.
#
# tmux setup: add to ~/.tmux.conf:
#   set -g allow-passthrough on
#   set -ga terminal-overrides ',*:allow-passthrough=on'


# ─────────────────────────────────────────────────────────────────────
# Extend mux detection: notifications.sh doesn't detect cmux.
# If cmux is active, override _NOTIFY_MUX to "cmux".
# ─────────────────────────────────────────────────────────────────────
if [ -n "${CMUX_WORKSPACE_ID:-}" ] || [ -n "${CMUX_SURFACE_ID:-}" ]; then
  _NOTIFY_MUX="cmux"
fi

# ─────────────────────────────────────────────────────────────────────
# set_tab_title — set the tab/pane title across multiplexers
#
# Uses cmux rename-tab, tmux rename-pane, zellij action rename-pane,
# screen -X title, or OSC 0 fallback (via _notify_emit for DCS
# passthrough in tmux/screen).
#
# Usage: set_tab_title "<full title>"
# ─────────────────────────────────────────────────────────────────────
set_tab_title() {
  if [ -z "${1:-}" ]; then
    echo "Usage: set_tab_title <title>" >&2
    return 1
  fi
  local title="$1"
  case "$_NOTIFY_MUX" in
  cmux)
    if command -v cmux >/dev/null 2>&1; then
      if [ -n "${CMUX_SURFACE_ID:-}" ]; then
        cmux rename-tab --surface "$CMUX_SURFACE_ID" "$title"
      else
        cmux rename-tab "$title"
      fi
    else
      # Fallback: OSC 0 (sets outer window title in cmux)
      _notify_emit "$(printf '\033]0;%s\007' "$title")"
    fi
    ;;
  tmux)
    if command -v tmux >/dev/null 2>&1; then
      tmux rename-pane "$title"
    else
      # Fallback: OSC 0 via DCS passthrough
      _notify_emit "$(printf '\033]0;%s\007' "$title")"
    fi
    ;;
  zellij)
    if command -v zellij >/dev/null 2>&1; then
      zellij action rename-pane "$title"
    else
      # Fallback: OSC 0 (zellij may forward natively)
      _notify_emit "$(printf '\033]0;%s\007' "$title")"
    fi
    ;;
  screen)
    if command -v screen >/dev/null 2>&1; then
      screen -X title "$title"
    else
      _notify_emit "$(printf '\033]0;%s\007' "$title")"
    fi
    ;;
  *)
    # No multiplexer — set window title via OSC 0
    _notify_emit "$(printf '\033]0;%s\007' "$title")"
    ;;
  esac
}

# ─────────────────────────────────────────────────────────────────────
# format_tab_title — build a tab title from indicator + workflow + project
#
# Usage: format_tab_title "<indicator>" "<workflow-slug>" "<project-slug>" [story-slug]
# Returns: "~ skill-src-upsert dotfiles-include" or "~ skill-src-upsert dotfiles-include 04-002-add-jwt"
# ─────────────────────────────────────────────────────────────────────
format_tab_title() {
  local indicator="${1:-}"
  local workflow="${2:-}"
  local project="${3:-}"
  local story="${4:-}"

  if [ -z "$indicator" ] || [ -z "$workflow" ] || [ -z "$project" ]; then
    echo "Usage: format_tab_title <indicator> <workflow-slug> <project-slug> [story-slug]" >&2
    return 1
  fi

  local title="${indicator} ${workflow} ${project}"
  if [ -n "$story" ]; then
    title="${title} ${story}"
  fi
  printf '%s' "$title"
}

# ─────────────────────────────────────────────────────────────────────
# status_to_indicator — map status words to indicator characters
#
# Usage: status_to_indicator "in-progress" → "~"
# ─────────────────────────────────────────────────────────────────────
status_to_indicator() {
  case "${1:-}" in
  in-progress|in_progress|progress|running|active) printf '~' ;;
  blocked|block|stuck|waiting) printf '!' ;;
  done|complete|completed|success|finished) printf 'x' ;;
  *) printf '%s' "${1:-~}" ;;  # passthrough if already an indicator
  esac
}

# ─────────────────────────────────────────────────────────────────────
# CLI entry point (only when executed, not sourced)
# ─────────────────────────────────────────────────────────────────────
if [ "${BASH_SOURCE[0]:-$0}" = "$0" ]; then
  _status=""
  _workflow=""
  _project=""
  _story=""
  _raw=""

  while [ $# -gt 0 ]; do
    case "$1" in
    --status)    _status="$2"; shift 2 ;;
    --workflow)  _workflow="$2"; shift 2 ;;
    --project)   _project="$2"; shift 2 ;;
    --story)     _story="$2"; shift 2 ;;
    --raw)       _raw="$2"; shift 2 ;;
    -h|--help)
      cat <<'HELP'
set-tab-title.sh — set terminal/multiplexer tab title with status indicator

Usage:
  set-tab-title.sh --status <status> --workflow <slug> --project <slug> [--story <slug>]
  set-tab-title.sh --raw "<full title>"

Status values (mapped to indicators):
  in-progress  →  ~   (in progress)
  blocked      →  !   (blocked)
  done         →  x   (done)

You can also pass an indicator directly (--status ~, --status !, --status x).

Examples:
  set-tab-title.sh --status in-progress --workflow skill-src-upsert --project dotfiles-include
  → sets tab title to: ~ skill-src-upsert dotfiles-include

  set-tab-title.sh --status blocked --workflow skill-src-upsert --project dotfiles-include --story 04-002-add-jwt
  → sets tab title to: ! skill-src-upsert dotfiles-include 04-002-add-jwt

  set-tab-title.sh --raw "~ skill-src-upsert dotfiles-include"
  → sets tab title to: ~ skill-src-upsert dotfiles-include
HELP
      exit 0 ;;
    *)
      # If a single positional arg is given, treat it as a raw title
      if [ -z "$_raw" ] && [ -z "$_status" ]; then
        _raw="$1"
      else
        echo "Unknown argument: $1" >&2
        exit 1
      fi
      shift ;;
    esac
  done

  if [ -n "$_raw" ]; then
    set_tab_title "$_raw"
  elif [ -n "$_status" ] && [ -n "$_workflow" ] && [ -n "$_project" ]; then
    _indicator="$(status_to_indicator "$_status")"
    _title="$(format_tab_title "$_indicator" "$_workflow" "$_project" "$_story")"
    set_tab_title "$_title"
  else
    echo "Error: must provide --raw <title> or --status + --workflow + --project" >&2
    echo "Run: set-tab-title.sh --help" >&2
    exit 1
  fi
fi
