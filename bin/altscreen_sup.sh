#!/bin/sh
# Keeps one altscreen_render --listen alive while the CarPlay alt screen is
# switched on (/mnt/app/altscreen_inject).  Started in the background by
# rgd_render_sup.sh, i.e. with the iAP2 session.  POSIX sh only: the unit has
# no awk, sed or pgrep on PATH.  Installed by tools/deploy-altscreen.sh.
BIN=/mnt/app/eso/hmi/lib/altscreen_render
# The renderer picks its own log (log_setup in altscreen_render.c); anything
# said before it gets there goes nowhere.
LOG=/dev/null
LOCK=/dev/shmem/altscreen_sup.pid
FLAG=/dev/shmem/altscreen_live
MARKER=/mnt/app/altscreen_inject
# libdisplayinit and the GL driver's libcgdrv, as for maneuver_render; at the
# end what the hardware decoder (NvSS) loads besides:
# libnvparser and libnvmedia.
LD_LIBRARY_PATH=/eso/lib:/mnt/app/eso/hmi/lib:/lib:/usr/lib:$LD_LIBRARY_PATH:/mnt/app/root/lib-target:/mnt/app/armle/lib:/mnt/app/armle/usr/lib
export LD_LIBRARY_PATH

[ -f "$MARKER" ] || exit 0
[ -x "$BIN" ] || exit 0

if [ -f "$LOCK" ]; then
    read old < "$LOCK"
    if [ -n "$old" ] && kill -0 "$old" 2>/dev/null; then exit 0; fi
fi
echo $$ > "$LOCK"

# /mnt/app is read-only after every boot, and then every log of the drive (the
# hook's, this one, the jar's) is silently lost, and the owner's cluster on/off
# switch cannot be saved (01.10.2026: a freeze after 15 min left no trace).
# Open it for the session; mount -uw on an already writable mount is harmless.
mount -uw /mnt/app 2>/dev/null

while [ -f "$MARKER" ]; do
    "$BIN" --listen >> "$LOG" 2>&1
    # A dead renderer must not leave the cluster on a context whose map
    # window is gone.
    rm -f "$FLAG"
    sleep 2
done
rm -f "$LOCK"
