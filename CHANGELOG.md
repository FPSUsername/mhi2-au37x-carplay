# Changelog

Each release is on the [Releases](https://github.com/chefranov/mhi2-au37x-carplay/releases)
page, with a ready-made SD card archive.

## v1.0.0 — 2026-10-15

The first numbered release. It contains everything below, plus:

- **The installer checks for other mods before changing anything.** It stops if MIBSI,
  mib2q-carplay-rgi or another wrapper around `mm-ipod` is installed, if `lsd.sh` puts other
  code on the HMI classpath, or if there are jars it does not recognise in
  `/mnt/app/eso/hmi/lsd/jars/`. Two mods that replace the same HMI classes can leave the
  main screen black. If you know the unknown jars are harmless, install with
  `IGNORE_CONFLICTS=1`, or put an empty `IGNORE_CONFLICTS` file on the card.
- **M.I.B.'s NavActiveIgnore is switched off.** It makes every CarPlay app state read 0,
  so the HMI loses track of what CarPlay owns. The installer renames the jar to
  `*.carplay-off`, and uninstalling renames it back.
- **SD card archives.** Copy the `mod` folder from the archive to the root of the card and
  run the M.I.B. script; there are no folders to create by hand. The `…-uninstall-sd.zip`
  archive removes everything the same way.
- The install log shows the release version.

## Before numbered releases

- **2026-10-13** — The installer also accepts `MHI2_*_AU276_*` (Audi Q2).
- **2026-10-12** — The installer stops on any firmware train other than `MHI2_*_AU37x_*`.
- **2026-10-11** — M.I.B. V3.6+: `/mod/command.sh` is now included, because that version's
  *Run individual script* runs it.
- **2026-10-10** — The CarPlay map in the cluster pauses while the stock map is shown and
  recovers after a reconnect. The cluster plate images are found on the 1024-px HMI too.
- **2026-10-07** — CarPlay map in the Virtual Cockpit, hardware-decoded. Installing with a
  part left out removes that part from a unit that had it.
- **2026-10-03** — The instruction text is cleared at the end of a route.
- **2026-10-01** — Maneuvers are drawn live on the head unit instead of played back from
  ~90 MB of pre-drawn pictures.
- **2026-09-19** — Route guidance on the Sport cluster layout. A track without artwork
  shows the default picture instead of the previous album.
- **2026-09-07** — Fixed route guidance showing only the straight-ahead arrow.
- **2026-09-06** — Route guidance: CarPlay maneuvers in the Virtual Cockpit.
- **2026-09-03** — Fixed the missing first cover of a session and stale artwork.
- **2026-08-31** — First publication: CarPlay cover art in the cluster and the touchpad
  as a D-pad.
