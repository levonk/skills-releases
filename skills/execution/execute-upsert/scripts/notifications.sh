#!/usr/bin/env sh
# shellcheck shell=sh

# =====================================================================
# Terminal Control: Notifications, Titles, and Pane Names
#
# Purpose:
#   - Unified terminal control via OSC escape sequences and mux commands.
#   - Desktop notifications (OSC 9 / OSC 777 / OSC 99 / cmux).
#   - Window and icon titles (OSC 0 / OSC 1 / OSC 2).
#   - Pane names (tmux rename-pane, zellij action rename-pane, screen title).
#   - Optional auto-title / auto-pane hooks that update the title and pane
#     name to reflect the current directory or running command.
#   - Auto-detect the active multiplexer and wrap OSC sequences in DCS
#     passthrough so they reach the outer terminal.
# Shell Support: bash, zsh, sh (POSIX-compliant where possible)
# Chezmoi: Managed by chezmoi, safe to source multiple times
# Security: No external calls (except cmux/zellij/tmux CLIs when used)
#
# Multiplexer Support:
#   zellij   - Native OSC forwarding + `zellij action rename-pane` CLI
#   herdr    - Native OSC forwarding (detects outer terminal)
#   tmux     - DCS passthrough (requires 3.3+ + allow-passthrough on)
#   screen   - DCS passthrough (standard)
#   byobu    - Inherits from tmux/screen (same passthrough requirement)
#
# Protocols:
#   OSC 0   - Set both icon and window title
#   OSC 1   - Set icon title only
#   OSC 2   - Set window title only
#   OSC 99  - kitty/otty rich notification protocol (title + body, urgency, IDs)
#   OSC 777 - rxvt-style simple notification protocol (title + body)
#   OSC 9   - iTerm2 / simple body-only notification protocol
#   cmux    - cmux notify CLI (when available)
#
# References:
#   https://www.xfree86.org/current/ctlseqs.html#OSC%20Operating%20System%20Commands
#   https://sw.kovidgoyal.net/kitty/desktop-notifications/
#   https://docs.otty.sh/vt/osc/osc-99
#   https://cmux.com/docs/notifications
#   https://github.com/tmux/tmux/wiki/FAQ#passthrough
#   https://zellij.dev/documentation/pane-rename.html
# =====================================================================

# Guard against re-sourcing
if [ -n "${_DOTFILES_TERMINAL_CONTROL_SOURCED:-}" ]; then
  return 0 2>/dev/null || exit 0
fi
_DOTFILES_TERMINAL_CONTROL_SOURCED=1

# Backwards-compat guard alias (previously notifications.sh used this)
if [ -z "${_DOTFILES_NOTIFICATIONS_SOURCED:-}" ]; then
  _DOTFILES_NOTIFICATIONS_SOURCED=1
fi


# #####################################################################
# Section 1: Multiplexer Detection & DCS Passthrough Helper
# #####################################################################
#
# tmux and GNU screen swallow unknown OSC sequences instead of
# forwarding them to the outer terminal. To get OSC sequences through,
# the sequence must be wrapped in a DCS (Device Control String)
# passthrough envelope:
#
#   tmux:   \ePtmux;\e\e<OSC payload with ESC doubled>\a\e\\
#   screen: \eP<OSC payload>\a\e\\
#
# zellij and herdr forward OSC sequences natively, so no wrapping is
# needed. byobu inherits from tmux or screen, so it's handled by the
# tmux/screen detection.
#
# Requirements:
#   tmux 3.3+ with `set -g allow-passthrough on` in ~/.tmux.conf
#   GNU screen with DCS passthrough (standard)

# Detect the active multiplexer (cached at source time)
# Note: cmux is checked before tmux/screen because cmux can embed other
# multiplexers — if we're inside cmux, cmux is the outermost surface
# manager and its CLI commands should be preferred for pane/workspace naming.
_OSC_MUX="none"
if [ -n "${CMUX_WORKSPACE_ID:-}" ] || [ -n "${CMUX_SURFACE_ID:-}" ]; then
  _OSC_MUX="cmux"
elif [ -n "${TMUX:-}" ]; then
  _OSC_MUX="tmux"
elif [ -n "${STY:-}" ]; then
  _OSC_MUX="screen"
elif [ -n "${ZELLIJ:-}" ] || [ -n "${ZELLIJ_SESSION_NAME:-}" ]; then
  _OSC_MUX="zellij"
elif [ -n "${HERDR_SESSION:-}" ] || [ -n "${HERDR_SOCKET:-}" ]; then
  _OSC_MUX="herdr"
fi

# Backwards-compat alias for the old variable name
_NOTIFY_MUX="$_OSC_MUX"

# _osc_emit — print an OSC/escape sequence, wrapped in DCS passthrough
# if running inside tmux or GNU screen.
#
# Usage: _osc_emit '<OSC sequence>'
# The sequence should already be complete (including terminator).
# For tmux, every ESC inside the payload is doubled.
_osc_emit() {
  local seq="$1"
  case "$_OSC_MUX" in
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
    # No multiplexer, or cmux/zellij/herdr (forward OSC natively)
    printf '%s' "$seq"
    ;;
  esac
}

# Backwards-compat alias: _notify_emit → _osc_emit
_notify_emit() { _osc_emit "$@"; }


# #####################################################################
# Section 2: Notifications
# #####################################################################
#
# Desktop notifications via terminal escape sequences or the cmux CLI.
# Auto-detect the best available mechanism with a single `notify`
# entry point.

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
  _osc_emit "$(printf '\e]777;notify;%s;%s\a' "$title" "$body")"
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
  _osc_emit "$seq"
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
  _osc_emit "$seq"
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
  _osc_emit "$(printf '\e]9;%s\e\\' "$message")"
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
# notify — high-level notification dispatcher
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


# #####################################################################
# Section 3: Window & Icon Titles
# #####################################################################
#
# Terminal window/icon titles via OSC escape sequences.
#
# OSC 0 — Set both icon and window title (most common)
# OSC 1 — Set icon title only (rarely used)
# OSC 2 — Set window title only
#
# Inside tmux with `set-titles on` + `allow-rename on`, OSC 0/2 set
# the pane title, which tmux propagates to the outer terminal via
# `set-titles-string`. Inside zellij, OSC 0/2 may pass through natively
# but `zellij action rename-pane` is more reliable for pane naming.
#
# IMPORTANT — cmux behavior:
# In cmux, OSC 0/1/2 set the outer macOS window title (the NSWindow
# title bar), NOT the pane/surface title shown in the pane header tabs.
# To set the pane/surface title in cmux, use `cmux rename-tab` (via
# set-pane-name) or the `title()` dispatcher which routes to it
# automatically. The `set-title` / `set-window-title` / `set-icon-title`
# functions still emit OSC 0/1/2 for setting the outer window title.

# ---------------------------------------------------------------------
# set-window-title — set the terminal window title (OSC 2)
# Usage: set-window-title "My Window Title"
# ---------------------------------------------------------------------
set-window-title() {
  if [ -z "${1:-}" ]; then
    echo "Usage: set-window-title <title>" >&2
    return 1
  fi
  _osc_emit "$(printf '\e]2;%s\a' "$1")"
}

# ---------------------------------------------------------------------
# set-icon-title — set the terminal icon title (OSC 1)
# Usage: set-icon-title "My Icon Title"
# ---------------------------------------------------------------------
set-icon-title() {
  if [ -z "${1:-}" ]; then
    echo "Usage: set-icon-title <title>" >&2
    return 1
  fi
  _osc_emit "$(printf '\e]1;%s\a' "$1")"
}

# ---------------------------------------------------------------------
# set-title — set both icon and window title (OSC 0)
# This is the most common title-setting OSC and is backwards
# compatible with the old set-title function from utilities.sh.
# Usage: set-title "My Title"
# ---------------------------------------------------------------------
set-title() {
  if [ -z "${1:-}" ]; then
    echo "Usage: set-title <title>" >&2
    return 1
  fi
  _osc_emit "$(printf '\e]0;%s\a' "$1")"
}

# ---------------------------------------------------------------------
# title — high-level title dispatcher
#
# Sets the most visible title for the current context:
#   1. cmux:   `cmux rename-tab` (sets the pane/surface header title)
#   2. zellij: `zellij action rename-pane` (sets the pane frame title)
#   3. All others: OSC 0 via _osc_emit (handles tmux/screen DCS
#      passthrough automatically)
#
# Note: In cmux, this sets the pane/surface title (the tab label above
# the pane), NOT the outer macOS window title. Use set-window-title
# for the outer window title.
#
# Usage: title "My Title"
# ---------------------------------------------------------------------
title() {
  if [ -z "${1:-}" ]; then
    echo "Usage: title <title>" >&2
    return 1
  fi
  case "$_OSC_MUX" in
  cmux)
    if command -v cmux >/dev/null 2>&1; then
      # Pass --surface explicitly because CMUX_TAB_ID may not resolve
      # as a tab ref (it can equal CMUX_WORKSPACE_ID in some contexts).
      # CMUX_SURFACE_ID reliably identifies the current surface.
      if [ -n "${CMUX_SURFACE_ID:-}" ]; then
        cmux rename-tab --surface "$CMUX_SURFACE_ID" "$1"
      else
        cmux rename-tab "$1"
      fi
    else
      # Fallback: OSC 0 (sets outer window title in cmux)
      set-title "$1"
    fi
    ;;
  zellij)
    if command -v zellij >/dev/null 2>&1; then
      zellij action rename-pane "$1"
    else
      set-title "$1"
    fi
    ;;
  *)
    set-title "$1"
    ;;
  esac
}


# #####################################################################
# Section 4: Pane Names & Workspace Names
# #####################################################################
#
# Pane names are the labels shown in the multiplexer's status bar or
# pane border. They are distinct from the terminal window title:
#
#   - cmux:   `cmux rename-tab <name>` (sets the surface/tab header title)
#             Shown in the pane header tab above each surface.
#   - tmux:   `tmux rename-pane <name>` or `tmux select-pane -T <name>`
#             Shown in pane border when `pane-border-status` is on.
#   - zellij: `zellij action rename-pane <name>`
#             Shown in pane frame when `pane_frames` is true.
#   - screen: `screen -X title <name>` (screen's "title" = window name)
#   - no mux: No pane concept; falls back to setting the window title
#             via OSC 0 so the function is still useful.
#
# Workspace names (cmux only):
#   - cmux:   `cmux rename-workspace <name>` (sets the sidebar workspace title)
#
# Note: In tmux with `allow-rename on`, OSC 0/2 from inside the pane
# also sets the pane title. So `set-title` and `set-pane-name` have
# overlapping effects in tmux. `set-pane-name` uses the explicit
# `tmux rename-pane` command for clarity.
#
# Note: In cmux, OSC 0/1/2 do NOT set the pane/surface title — they
# only set the outer macOS window title. `cmux rename-tab` is required
# for pane/surface titles.

# ---------------------------------------------------------------------
# set-pane-name — set the active pane's name in the current multiplexer
#
# Usage: set-pane-name "my-pane"
# Returns 0 on success, 1 if no multiplexer is detected (falls back to
# set-title so the call is never a complete no-op).
# ---------------------------------------------------------------------
set-pane-name() {
  if [ -z "${1:-}" ]; then
    echo "Usage: set-pane-name <name>" >&2
    return 1
  fi
  local name="$1"
  case "$_OSC_MUX" in
  cmux)
    if command -v cmux >/dev/null 2>&1; then
      # Pass --surface explicitly because CMUX_TAB_ID may not resolve
      # as a tab ref (it can equal CMUX_WORKSPACE_ID in some contexts).
      # CMUX_SURFACE_ID reliably identifies the current surface.
      if [ -n "${CMUX_SURFACE_ID:-}" ]; then
        cmux rename-tab --surface "$CMUX_SURFACE_ID" "$name"
      else
        cmux rename-tab "$name"
      fi
    else
      # Fallback: OSC 0 (sets outer window title in cmux)
      set-title "$name"
    fi
    ;;
  tmux)
    if command -v tmux >/dev/null 2>&1; then
      tmux rename-pane "$name"
    else
      # Fallback: OSC 0 (tmux will pick it up if allow-rename is on)
      set-title "$name"
    fi
    ;;
  zellij)
    if command -v zellij >/dev/null 2>&1; then
      zellij action rename-pane "$name"
    else
      # Fallback: OSC 0 (zellij may forward it natively)
      set-title "$name"
    fi
    ;;
  screen)
    if command -v screen >/dev/null 2>&1; then
      screen -X title "$name"
    else
      set-title "$name"
    fi
    ;;
  *)
    # No multiplexer — no pane concept. Fall back to window title
    # so the function is still useful.
    set-title "$name"
    ;;
  esac
}

# ---------------------------------------------------------------------
# pane-name — alias for set-pane-name (parallel to `title` / `notify`)
# ---------------------------------------------------------------------
pane-name() { set-pane-name "$@"; }

# ---------------------------------------------------------------------
# set-workspace-name — set the active workspace name (cmux only)
#
# In cmux, workspaces are the top-level organizational unit shown in
# the sidebar. This function renames the current workspace. In other
# multiplexers, it falls back to set-pane-name since they don't have
# a separate workspace concept.
#
# Usage: set-workspace-name "My Workspace"
# ---------------------------------------------------------------------
set-workspace-name() {
  if [ -z "${1:-}" ]; then
    echo "Usage: set-workspace-name <name>" >&2
    return 1
  fi
  local name="$1"
  case "$_OSC_MUX" in
  cmux)
    if command -v cmux >/dev/null 2>&1; then
      # Use the new `cmux workspace rename` form; the old
      # `cmux rename-workspace` is a deprecated alias that prints
      # a notice on stderr. CMUX_QUIET=1 silences it if needed.
      cmux workspace rename "$name" 2>/dev/null || \
        cmux rename-workspace "$name" 2>/dev/null
    else
      echo "set-workspace-name: cmux CLI not found" >&2
      return 1
    fi
    ;;
  *)
    # No cmux — fall back to set-pane-name
    set-pane-name "$name"
    ;;
  esac
}

# ---------------------------------------------------------------------
# workspace-name — alias for set-workspace-name
# ---------------------------------------------------------------------
workspace-name() { set-workspace-name "$@"; }


# #####################################################################
# Section 5: Auto-Title & Auto-Pane Hooks
# #####################################################################
#
# Automatically update the terminal title and pane name to reflect
# the current directory (at prompt) or the running command (during
# execution). This mirrors the behavior of many terminal/mux setups
# where the title tracks what you're doing.
#
# Enable with `title_auto_on` / `pane_auto_on` / `terminal_auto_on`.
# Disable with `title_auto_off` / `pane_auto_off` / `terminal_auto_off`.
#
# Or set DOTFILES_AUTO_TITLE=1 before sourcing to enable automatically.
#
# Configuration:
#   DOTFILES_AUTO_TITLE_FORMAT_PROMPT
#     Format for title at prompt. Default: '%d' (cwd).
#     Supported: %d (cwd), %D (cwd basename), %h (hostname), %u (user)
#   DOTFILES_AUTO_TITLE_FORMAT_COMMAND
#     Format for title during command. Default: '%s' (command string).
#     Supported: %s (command), %d (cwd), %h (hostname)
#   DOTFILES_AUTO_PANE_FORMAT_PROMPT
#     Format for pane name at prompt. Default: '%D' (cwd basename).
#   DOTFILES_AUTO_PANE_FORMAT_COMMAND
#     Format for pane name during command. Default: '%s' (command).
#
# Note: Auto-pane hooks use `set-pane-name` which calls tmux/zellij
# CLI commands. These are slightly heavier than pure OSC emission but
# are the only reliable way to set pane names. If you prefer
# OSC-only (which works in tmux with allow-rename), use
# `title_auto_on` alone — it will also set the pane title in tmux.

# Track whether auto hooks are active
_DOTFILES_AUTO_TITLE_ON=0
_DOTFILES_AUTO_PANE_ON=0

# __tc_expand_format — expand a format string with context
# Usage: __tc_expand_format <format> [command_string]
__tc_expand_format() {
  local fmt="$1"
  local cmd="${2:-}"
  local cwd="${PWD:-?}"
  local host="${HOSTNAME:-$(hostname 2>/dev/null || echo '?')}"
  local user="${USER:-$(whoami 2>/dev/null || echo '?')}"
  local cwd_base="${cwd##*/}"
  [ -z "$cwd_base" ] && cwd_base="/"

  # Expand each placeholder
  local result="$fmt"
  result="${result//%d/$cwd}"
  result="${result//%D/$cwd_base}"
  result="${result//%h/$host}"
  result="${result//%u/$user}"
  result="${result//%s/$cmd}"
  printf '%s' "$result"
}

# __tc_precmd — hook run before each prompt
# Sets title/pane to the prompt format (cwd by default).
__tc_precmd() {
  local exit_code=$?
  if [ "$_DOTFILES_AUTO_TITLE_ON" = "1" ]; then
    local fmt="${DOTFILES_AUTO_TITLE_FORMAT_PROMPT:-%d}"
    set-title "$(__tc_expand_format "$fmt")"
  fi
  if [ "$_DOTFILES_AUTO_PANE_ON" = "1" ]; then
    local fmt="${DOTFILES_AUTO_PANE_FORMAT_PROMPT:-%D}"
    set-pane-name "$(__tc_expand_format "$fmt")"
  fi
  return $exit_code
}

# __tc_preexec — hook run before each command
# Sets title/pane to the command format (command name by default).
# In bash, $1 is the full command string. In zsh, $1 is also the
# full command string.
__tc_preexec() {
  if [ "$_DOTFILES_AUTO_TITLE_ON" = "1" ]; then
    local fmt="${DOTFILES_AUTO_TITLE_FORMAT_COMMAND:-%s}"
    set-title "$(__tc_expand_format "$fmt" "$1")"
  fi
  if [ "$_DOTFILES_AUTO_PANE_ON" = "1" ]; then
    local fmt="${DOTFILES_AUTO_PANE_FORMAT_COMMAND:-%s}"
    set-pane-name "$(__tc_expand_format "$fmt" "$1")"
  fi
}

# ---------------------------------------------------------------------
# title_auto_on — enable automatic title updates
# Registers precmd/preexec hooks for the current shell.
# ---------------------------------------------------------------------
title_auto_on() {
  if [ "$_DOTFILES_AUTO_TITLE_ON" = "1" ]; then
    return 0
  fi
  _DOTFILES_AUTO_TITLE_ON=1

  # zsh: use precmd_functions / preexec_functions arrays
  if [ -n "${ZSH_VERSION:-}" ]; then
    precmd_functions+=(__tc_precmd)
    preexec_functions+=(__tc_preexec)
  # bash: use PROMPT_COMMAND and DEBUG trap
  elif [ -n "${BASH_VERSION:-}" ]; then
    PROMPT_COMMAND="__tc_precmd; ${PROMPT_COMMAND:-}"
    trap '__tc_preexec "$BASH_COMMAND"' DEBUG
  else
    # POSIX sh: no preexec hook available; precmd via PROMPT_COMMAND
    # if the shell supports it. Best-effort only.
    echo "title_auto_on: limited support in POSIX sh (no preexec)" >&2
  fi
}

# ---------------------------------------------------------------------
# title_auto_off — disable automatic title updates
# ---------------------------------------------------------------------
title_auto_off() {
  _DOTFILES_AUTO_TITLE_ON=0
  if [ -n "${ZSH_VERSION:-}" ]; then
    # Remove __tc_precmd from precmd_functions
    local new_funcs=""
    local f
    for f in "${precmd_functions[@]}"; do
      [ "$f" != "__tc_precmd" ] && new_funcs="${new_funcs} ${f}"
    done
    precmd_functions=($new_funcs)
    new_funcs=""
    for f in "${preexec_functions[@]}"; do
      [ "$f" != "__tc_preexec" ] && new_funcs="${new_funcs} ${f}"
    done
    preexec_functions=($new_funcs)
  elif [ -n "${BASH_VERSION:-}" ]; then
    trap - DEBUG
    # Best-effort: remove __tc_precmd from PROMPT_COMMAND
    PROMPT_COMMAND="${PROMPT_COMMAND//__tc_precmd; /}"
    PROMPT_COMMAND="${PROMPT_COMMAND//__tc_precmd/}"
  fi
}

# ---------------------------------------------------------------------
# pane_auto_on — enable automatic pane name updates
# ---------------------------------------------------------------------
pane_auto_on() {
  if [ "$_DOTFILES_AUTO_PANE_ON" = "1" ]; then
    return 0
  fi
  _DOTFILES_AUTO_PANE_ON=1

  if [ -n "${ZSH_VERSION:-}" ]; then
    precmd_functions+=(__tc_precmd)
    preexec_functions+=(__tc_preexec)
  elif [ -n "${BASH_VERSION:-}" ]; then
    PROMPT_COMMAND="__tc_precmd; ${PROMPT_COMMAND:-}"
    trap '__tc_preexec "$BASH_COMMAND"' DEBUG
  else
    echo "pane_auto_on: limited support in POSIX sh (no preexec)" >&2
  fi
}

# ---------------------------------------------------------------------
# pane_auto_off — disable automatic pane name updates
# ---------------------------------------------------------------------
pane_auto_off() {
  _DOTFILES_AUTO_PANE_ON=0
  # Only remove hooks if title auto is also off (they share the same
  # hook functions)
  if [ "$_DOTFILES_AUTO_TITLE_ON" = "0" ]; then
    if [ -n "${ZSH_VERSION:-}" ]; then
      local new_funcs=""
      local f
      for f in "${precmd_functions[@]}"; do
        [ "$f" != "__tc_precmd" ] && new_funcs="${new_funcs} ${f}"
      done
      precmd_functions=($new_funcs)
      new_funcs=""
      for f in "${preexec_functions[@]}"; do
        [ "$f" != "__tc_preexec" ] && new_funcs="${new_funcs} ${f}"
      done
      preexec_functions=($new_funcs)
    elif [ -n "${BASH_VERSION:-}" ]; then
      trap - DEBUG
      PROMPT_COMMAND="${PROMPT_COMMAND//__tc_precmd; /}"
      PROMPT_COMMAND="${PROMPT_COMMAND//__tc_precmd/}"
    fi
  fi
}

# ---------------------------------------------------------------------
# terminal_auto_on — enable both title and pane auto updates
# ---------------------------------------------------------------------
terminal_auto_on() {
  title_auto_on
  pane_auto_on
}

# ---------------------------------------------------------------------
# terminal_auto_off — disable both title and pane auto updates
# ---------------------------------------------------------------------
terminal_auto_off() {
  title_auto_off
  pane_auto_off
}

# Enable automatically if requested via environment variable
if [ "${DOTFILES_AUTO_TITLE:-0}" = "1" ]; then
  terminal_auto_on
fi


# #####################################################################
# Section 6: Probe / Discovery Helpers
# #####################################################################

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
  printf 'Detected multiplexer: %s\n' "$_OSC_MUX" >&2
  case "$_OSC_MUX" in
  cmux)
    printf '  (cmux forwards OSC natively + cmux notify CLI)\n' >&2
    ;;
  tmux)
    printf '  (tmux DCS passthrough active — requires allow-passthrough on)\n' >&2
    ;;
  screen)
    printf '  (GNU screen DCS passthrough active)\n' >&2
    ;;
  zellij)
    printf '  (zellij forwards OSC natively + rename-pane CLI)\n' >&2
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
# title_probe — test title setting via each method
#
# Sets the title to a test string via OSC 0, OSC 1, OSC 2, and the
# high-level `title` dispatcher. Watch your terminal title bar and
# tmux/zellij pane border to see which ones work.
#
# Usage: title_probe [delay_seconds]
# ---------------------------------------------------------------------
title_probe() {
  local delay="${1:-1}"
  printf 'Testing title-setting methods...\n' >&2
  printf 'Detected multiplexer: %s\n' "$_OSC_MUX" >&2

  if [ "$_OSC_MUX" = "cmux" ]; then
    printf '  NOTE: In cmux, OSC 0/1/2 set the outer macOS window title,\n' >&2
    printf '  NOT the pane/surface title. Use title() or set-pane-name()\n' >&2
    printf '  for pane titles (they use cmux rename-tab).\n' >&2
  fi

  printf '  [1/5] OSC 0 (icon + window title)...' >&2
  set-title "OSC 0 test — both titles"
  printf ' done\n' >&2
  [ "$delay" -gt 0 ] 2>/dev/null && command -v sleep >/dev/null 2>&1 && sleep "$delay"

  printf '  [2/5] OSC 1 (icon title only)...' >&2
  set-icon-title "OSC 1 test — icon only"
  printf ' done\n' >&2
  [ "$delay" -gt 0 ] 2>/dev/null && command -v sleep >/dev/null 2>&1 && sleep "$delay"

  printf '  [3/5] OSC 2 (window title only)...' >&2
  set-window-title "OSC 2 test — window only"
  printf ' done\n' >&2
  [ "$delay" -gt 0 ] 2>/dev/null && command -v sleep >/dev/null 2>&1 && sleep "$delay"

  printf '  [4/5] title() dispatcher...' >&2
  title "title() dispatcher test"
  printf ' done\n' >&2
  [ "$delay" -gt 0 ] 2>/dev/null && command -v sleep >/dev/null 2>&1 && sleep "$delay"

  printf '  [5/5] set-pane-name()...' >&2
  set-pane-name "pane name test"
  printf ' done\n' >&2

  printf 'Check your terminal title bar and mux pane border/header.\n' >&2
  printf 'Restore with: set-title "my title" or title_auto_on\n' >&2
}

# ---------------------------------------------------------------------
# pane_probe — test pane naming via each mux method
#
# Sets the pane name via the mux-specific command (tmux rename-pane,
# zellij action rename-pane, screen title) and reports which method
# was used.
#
# Usage: pane_probe
# ---------------------------------------------------------------------
pane_probe() {
  printf 'Testing pane naming...\n' >&2
  printf 'Detected multiplexer: %s\n' "$_OSC_MUX" >&2

  case "$_OSC_MUX" in
  cmux)
    if command -v cmux >/dev/null 2>&1; then
      printf '  cmux rename-tab --surface... ' >&2
      if [ -n "${CMUX_SURFACE_ID:-}" ]; then
        cmux rename-tab --surface "$CMUX_SURFACE_ID" "pane_probe test" 2>/dev/null
      else
        cmux rename-tab "pane_probe test" 2>/dev/null
      fi
      printf 'done\n' >&2
      printf 'Check pane header tab above the surface.\n' >&2
      printf 'Also testing cmux workspace rename... ' >&2
      cmux workspace rename "pane_probe ws test" 2>/dev/null && printf 'done\n' >&2 || printf 'skipped\n' >&2
    else
      printf '  cmux not found — falling back to OSC 0\n' >&2
      set-title "pane_probe test (OSC 0 fallback)"
    fi
    ;;
  tmux)
    if command -v tmux >/dev/null 2>&1; then
      printf '  tmux rename-pane... ' >&2
      tmux rename-pane "pane_probe test"
      printf 'done\n' >&2
      printf 'Check pane border (requires pane-border-status on).\n' >&2
    else
      printf '  tmux not found — falling back to OSC 0\n' >&2
      set-title "pane_probe test (OSC 0 fallback)"
    fi
    ;;
  zellij)
    if command -v zellij >/dev/null 2>&1; then
      printf '  zellij action rename-pane... ' >&2
      zellij action rename-pane "pane_probe test"
      printf 'done\n' >&2
      printf 'Check pane frame (requires pane_frames true).\n' >&2
    else
      printf '  zellij not found — falling back to OSC 0\n' >&2
      set-title "pane_probe test (OSC 0 fallback)"
    fi
    ;;
  screen)
    if command -v screen >/dev/null 2>&1; then
      printf '  screen title... ' >&2
      screen -X title "pane_probe test"
      printf 'done\n' >&2
    else
      printf '  screen not found — falling back to OSC 0\n' >&2
      set-title "pane_probe test (OSC 0 fallback)"
    fi
    ;;
  *)
    printf '  no multiplexer — using OSC 0 (sets window title)\n' >&2
    set-title "pane_probe test (no mux)"
    ;;
  esac
}

# ---------------------------------------------------------------------
# terminal_probe — probe all terminal control features at once
# Runs notify_probe, title_probe, and pane_probe in sequence.
# Usage: terminal_probe [delay_seconds]
# ---------------------------------------------------------------------
terminal_probe() {
  local delay="${1:-1}"
  printf '=== Terminal Control Probe ===\n\n' >&2
  printf '--- Notifications ---\n' >&2
  notify_probe "$delay"
  printf '\n--- Titles ---\n' >&2
  title_probe "$delay"
  printf '\n--- Pane Names ---\n' >&2
  pane_probe
  printf '\n=== Probe complete ===\n' >&2
}


# #####################################################################
# Section 7: Reference
# #####################################################################
#
# Feature comparison:
#
# Feature              OSC 99   cmux OSC 99  OSC 777   OSC 9   cmux CLI
# --- Notifications ---
# Title + body         Yes      Yes          Yes       No      Yes
# Subtitle             No       Yes          No        No      Yes
# Notification ID      Yes      Yes          No        No      No
# Urgency levels       Yes      No           No        No      No
# Chunked payloads     Yes      Yes          No        No      No
# Complexity           Higher   Higher       Lower     Lowest  N/A (CLI)
#
# Feature              OSC 0    OSC 1        OSC 2     title()  set-pane-name()
# --- Titles ---
# Sets outer win title Yes      No           Yes       varies   varies
# Sets icon title      Yes      Yes          No        No       No
# Sets pane/surf title No       No           No        cmux     cmux/tmux/zellij
# tmux passthrough     Yes      Yes          Yes       Yes      Yes (CLI)
# zellij native        Maybe    Maybe        Maybe     Yes      Yes (CLI)
# cmux native          Yes      Yes          Yes       Yes      Yes (CLI)
#
# Feature              cmux     tmux         zellij    screen   no mux
# --- Pane Names ---
# set-pane-name        CLI      CLI          CLI       CLI      OSC 0 fallback
# set-workspace-name   CLI      N/A          N/A       N/A      N/A
# Auto-update hooks    Yes      Yes          Yes       Yes      N/A
#
# Multiplexer support (all OSC wrapped in DCS passthrough as needed):
# Multiplexer   OSC support    Pane naming              Workspace naming
# cmux          Native fwd     `cmux rename-tab`        `cmux rename-workspace`
# zellij        Native fwd     `zellij action rename-pane`  N/A
# herdr         Native fwd     N/A (no pane concept)    N/A
# tmux          DCS wrap       `tmux rename-pane`       N/A
# screen        DCS wrap       `screen -X title`        N/A
# byobu         Inherited      Inherited from tmux/screen  N/A
# none          Direct OSC     N/A (falls back to OSC 0)   N/A
#
# Usage guide:
#   notify "Title" "Body"              # auto-detect best notification method
#   set-title "My Title"               # set outer window+icon title (OSC 0)
#   set-window-title "My Title"        # set outer window title only (OSC 2)
#   set-icon-title "My Title"          # set icon title only (OSC 1)
#   title "My Title"                   # set most visible title (pane/surface)
#   set-pane-name "my-pane"            # set pane/surface name in current mux
#   set-workspace-name "my-ws"         # set workspace name (cmux only)
#   title_auto_on                      # auto-update title to cwd/command
#   pane_auto_on                       # auto-update pane name to cwd/command
#   terminal_auto_on                   # enable both auto-title and auto-pane
#   notify_probe                       # test notification protocols
#   title_probe                        # test title-setting methods
#   pane_probe                         # test pane-naming methods
#   terminal_probe                     # test everything at once
#
# cmux notes:
#   - OSC 0/1/2 set the outer macOS window title, NOT pane/surface titles
#   - Use `title()` or `set-pane-name()` for pane titles (cmux rename-tab)
#   - Use `set-workspace-name()` for workspace titles (cmux rename-workspace)
#   - cmux config: ~/.config/cmux/cmux.json
#     "app": { "windowTitleTemplate": "[cmux:{windowToken}] {activeWorkspace}" }
#
# tmux setup (already in dot_tmux.conf):
#   set -g allow-passthrough on
#   set -g set-titles on
#   set -g set-titles-string '#S:#I.#P - #T'
#   setw -g allow-rename on
#   setw -g pane-border-status top
#   setw -g pane-border-format ' #T '
#
# zellij setup (already in config.kdl):
#   pane_frames true
#   # Rename pane keybind: bind "T" { Run "zellij" "action" "rename-pane"; }

