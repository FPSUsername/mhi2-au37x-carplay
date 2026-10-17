# Changelog

Each release is on the [Releases](https://github.com/chefranov/mhi2-au37x-carplay/releases)
page, with a ready-made SD card archive.

## v1.1.2 — 2026-10-17

- **The parking popup beside CarPlay is installed only on firmware it was checked
  against** (P5089, Q2 P5088). It replaces stock HMI classes, and on other firmware they
  differ: on CN P0916 v1.1.0 left the unit on the start logo (#27). Elsewhere the
  installer leaves it out and removes a copy an earlier release put there; `PDC=1`, or an
  empty `PDC` file on the card, installs it anyway.
- The cluster-map worker no longer spins while the cluster's display manager is still
  starting. It used about 10 % CPU for the first minute after every start (#26).

## v1.1.1 — 2026-10-17

- **The missed-call indicator in the cluster clears.** The Tel key on the steering wheel
  or opening the phone on the head unit clears it, as with a Bluetooth phone. Before, it
  stayed lit until the next answered or outgoing call. Calls missed before the phone was
  connected no longer light it: the iPhone already shows them.

## v1.1.0 — 2026-10-17

- **The cluster's phone tab works with CarPlay.** Instead of "Your iPhone is in Apple
  CarPlay mode" it shows calls as with a Bluetooth phone: caller and number, calling,
  ringing, in call with a timer, on hold. Accept, end, hold, swap, mute and dialling from
  recents and favourites work from the cluster, and it shows the phone's signal and
  carrier.
- **The Tel key goes straight to CarPlay**, with no "Switch to Apple CarPlay" popup, and
  so does Phone in the main menu.
- **Siri on a short press of the voice key.** A long press works as before; without
  CarPlay the short press starts the car's own voice control.
- **Parking sensors keep CarPlay on screen.** The side sensors open their popup beside
  CarPlay instead of the full parking screen. Reverse gear is unchanged.
- **No empty maneuver tile off the road.** With a route on the phone but the car off it,
  the cluster closes its maneuver tile instead of showing a straight arrow that pointed
  nowhere; it comes back with the first turn.
- **Lane guidance along the whole route**, not only at its start, with lane arrows drawn
  like the stock head-up display's.
- An empty `WIRELESS_MAP` file on the card offers the cluster map to wireless adapters
  that do not ask for it, such as the Carlinkit 2Air (#25). Off by default.
- The installer checks for another mod's `LD_PRELOAD` in `dio_manager` before changing
  anything. Before, it found it only after the jars were already copied.

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
