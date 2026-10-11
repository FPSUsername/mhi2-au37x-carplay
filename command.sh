#!/bin/sh
#
# command.sh - M.I.B. V3.x entry point.
#
# Newer M.I.B. releases (V3.6, V3.7) have no "Run Custom Script"; their
# Advanced Settings -> Run individual script runs /mod/command.sh and prints
# "Nothing to do!" when it is missing. This only hands over to custom.sh,
# which sits beside it on the card, so either menu item installs the same way.

case $0 in
    */*) SELF_DIR=${0%/*} ;;
    *)   SELF_DIR=. ;;
esac

if [ ! -f "$SELF_DIR/custom.sh" ]; then
    echo "!! custom.sh not found next to command.sh ($SELF_DIR)."
    echo "!! Copy both to /mod/ on the card, and the repository to /mod/carplay/."
    exit 1
fi

exec sh "$SELF_DIR/custom.sh"
