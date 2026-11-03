#!/usr/bin/env bash
# Man pages for the C and C++ standard libraries, for use from nvim (:Man, K).
#
#   install-man-docs.sh            install packages + link whatever cppman has cached
#   install-man-docs.sh install    apt packages only (asks for sudo)
#   install-man-docs.sh cache      download ALL cppreference pages (long: ~hours)
#   install-man-docs.sh link       (re)link cppman's cached pages into man's path
#
# What you get:
#   man 3 printf / qsort / malloc   C library          (manpages-dev)
#   man 3p fopen, man 0p stdio.h    POSIX / C headers  (manpages-posix[-dev])
#   man std::vector, std::map ...   C++ library        (cppman -> cppreference.com)
#
# Debian/Ubuntu (and Ubuntu on WSL). On Windows, nvim reaches these through WSL,
# see lua/config/winman.lua.
set -eu

MAN_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/man"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/cppman/cppreference.com"

install_pkgs() {
  sudo apt-get update -qq
  sudo apt-get install -y man-db manpages manpages-dev manpages-posix manpages-posix-dev cppman
}

# cppman keeps one gzip'd groff page per symbol, e.g. "std::vector.3.gz", but
# its own man integration doesn't create the manN/ layout `man` needs.
# ~/.manpath puts the dir on man's search path regardless of $PATH (man only
# adds ~/.local/share/man by itself when ~/.local/bin is on PATH, which isn't
# true for non-login shells such as `wsl.exe -e man` from Windows nvim).
link_pages() {
  if [ ! -d "$CACHE" ]; then
    echo "no cppman cache yet -- view a page once ('cppman std::vector') or run: $0 cache" >&2
    return 0
  fi
  mkdir -p "$MAN_HOME/man3"
  grep -qsxF "MANDATORY_MANPATH $MAN_HOME" "$HOME/.manpath" \
    || echo "MANDATORY_MANPATH $MAN_HOME" >> "$HOME/.manpath"
  n=0
  for f in "$CACHE"/*.3.gz; do
    [ -e "$f" ] || continue
    ln -sf "$f" "$MAN_HOME/man3/$(basename "$f")"
    n=$((n + 1))
  done
  mandb -q --user-db 2>/dev/null || true
  echo "linked $n cppman pages into $MAN_HOME/man3"
}

case "${1:-all}" in
  install) install_pkgs ;;
  cache) printf 'y\n' | cppman -c && link_pages ;;
  link) link_pages ;;
  all) install_pkgs && link_pages ;;
  *) echo "usage: $0 [install|cache|link]" >&2; exit 2 ;;
esac
