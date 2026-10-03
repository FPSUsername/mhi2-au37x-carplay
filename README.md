# MHI2 AU37x CarPlay patches

Three patches for Audi MHI2 head units on the **`MHI2_ER_AU37x`** train:

- **Route guidance (RGI)** — CarPlay turn-by-turn maneuvers in the Virtual Cockpit:
  the arrow, the distance to it and the street, in the cluster's own maneuver tile.
  Stock shows them only for the built-in navigation. The arrow is drawn live on the
  head unit, in 3D, over the cluster's own map.
- **Cover art** — CarPlay album artwork on the Virtual Cockpit's now-playing widget.
  Stock forwards title/artist/album to the cluster but never the picture.
- **Touchpad → D-pad** — the MMI touchpad navigates CarPlay menus. Stock bridges the
  rotary, the knob press, back and the softkeys, but leaves the touchpad dead.

Prebuilt binaries only. Two ways to install: straight over a network cable, or from an
M.I.B. SD card.

> **Use at your own risk.** These patches copy files onto the head unit's flash and edit
> one system config. Everything is reversible and the installer backs up the one file it
> changes, but a head unit is not a toy. Read
> [Recovery](https://github.com/chefranov/mhi2-au37x-carplay/wiki/Troubleshooting#recovery) *before* you start, and make sure you can
> get a shell on the unit without the screen.

<p align="center"><img src="docs/rgi-demo.gif" width="80%" /></p>

<p align="center"><sub>A CarPlay maneuver in the cluster, animated, with the distance counting down.</sub></p>

<p align="center"><img src="docs/rgi.jpg" width="80%" /></p>

<p align="center"><sub>Roundabout, second exit, 50 m — drawn in the cluster's own maneuver tile.</sub></p>

<p align="center"><img src="docs/coverart.jpg" width="80%" /></p>

<p align="center"><sub>CarPlay album art on the Virtual Cockpit — stock leaves this tile empty.</sub></p>

## Will it work on my car?

Tested on exactly one build: `MHI2_ER_AU37x_P5089`, `MU1326`, part `8V1035036A`, an Audi
A3 8V Sportback e-tron (2017) with the Virtual Cockpit and the HARMAN iAP2 stack.

Other `MHI2_ER_AU37x_*` builds are expected to work but are not verified. Two things
decide it, and one of them can keep the HMI from starting — **[read Compatibility before
installing](https://github.com/chefranov/mhi2-au37x-carplay/wiki/Compatibility)**.

Three requirements worth knowing up front:

- **Cover art needs the cluster coded for it**: module **17**, adaptation
  `Picture_Upload_Download` set to **active**. Without it the cluster never asks for a
  picture and nothing on the head-unit side can help.
- **The D-pad patch needs no coding**, and is self-contained: copy `bin/dpad_hook.jar`
  into `/mnt/app/eso/hmi/lsd/jars/` and you are done. It is the lowest-risk way to try
  any of this.
- **Route guidance needs no coding either**, but it runs a renderer process of its
  own and replaces the `mm-ipod` binary on `/mnt/app` with a small shim that starts
  it (the original is kept beside it). About 1.5 MB of files, no longer the 90 MB
  earlier releases needed. Skip it at install time with `RGI=0`, or turn it off
  later with one file — see below. It follows the cluster's layout, classic or
  sport, by itself.

### The sport cluster layout

The Virtual Cockpit has two layouts, and route guidance draws for both. On the
**sport** layout — one rev counter in the middle, the side areas on black — the
small-stage tile sits on the cluster's own black panel, the picture centred at the
bottom of it; the wide tile is the same as on the classic layout, because that is what
the cluster itself does.

The layout is detected by itself: switch it in the cluster's menu and the tile follows
within about five seconds. Nothing to set.

Should you ever need to force it — say, to compare the two — a marker file wins while
it exists:

```sh
ssh root@172.16.250.248 'mount -uw /mnt/app; touch /mnt/app/rgd_sport'   # force sport
ssh root@172.16.250.248 'mount -uw /mnt/app; rm /mnt/app/rgd_sport'      # back to automatic
```

No reboot needed. At install time the same is `SPORT=1 sh install.sh`, or an empty file
named `SPORT` next to `install.sh` on the SD card.

### No shader compiler, and what that means for you

Nothing, in use — it is worth knowing only because it shapes what is in `bin/`.

The GL driver on these units looks for NVIDIA's shader-compiler plugin and the firmware
does not ship it, so `glCompileShader` fails on this hardware for any shader at all.
What does work is `glShaderBinary`: the driver takes a shader already compiled into its
own binary format. `bin/shaders/` holds the four the renderer needs, in that format, and
the renderer loads them instead of compiling anything. The `.glsl` sources they were
built from are in the development repository.

The practical consequence is that **the shaders cannot be edited on the unit**, and a
build of the renderer has to travel with the matching blobs. If a blob is missing the
renderer falls back to compiling the source, which on this firmware simply fails, and
the cluster tile stays empty — the renderer's log says which path each shader took.

### Lane guidance

When the phone publishes lane information, it is drawn as a strip of arrows along the
bottom of the tile: the lanes you may take highlighted, the others dimmed, up to eight
of them with an overflow marker beyond that. Apple Maps and Google Maps both publish it
on motorway junctions.

Exercised so far against recorded and synthetic route data, not yet confirmed on a live
route in traffic. If the strip misbehaves, it hides with everything else when route
guidance is switched off.

### Which navigation apps work

Route guidance draws whatever the phone publishes over CarPlay, so it depends on the app:

| App | Maneuvers in the cluster |
|---|---|
| **Apple Maps** | yes |
| **Google Maps** | yes |
| Waze | no — Waze publishes no route-guidance data over CarPlay at all |

Waze is not a limitation of this patch and there is nothing here to fix: no data leaves
the phone. If a future Waze build starts sending it, maneuvers will appear with no
change on this side.

## Contents

| Path | What it is |
|---|---|
| `bin/rgd_hook.jar` | HMI patch: turns the phone's route guidance into cluster maneuvers and drives the maneuver tile |
| `bin/librgd_hook.so` | Native hook (ARM/QNX), `LD_PRELOAD`ed into `mm-ipod`: asks iOS for route guidance and forwards it |
| `bin/maneuver_render` | The renderer (ARM/QNX): a process of its own that draws the maneuver live into a window the cluster composites over the head unit's map |
| `bin/shaders/` | The renderer's shaders, compiled. This firmware ships no GLSL compiler, so they are shipped as platform binaries — see "No shader compiler" below |
| `bin/flag_atlas.rgba` | Texture atlas for the animated destination flag |
| `bin/rgd_blank.png` | A fully transparent bitmap. The HMI creates the overlay from it before the renderer has drawn its first frame |
| `bin/coverart_hook.jar` | HMI patch: pushes the artwork to the cluster and answers its picture requests |
| `bin/dpad_hook.jar` | HMI patch: touchpad drag → CarPlay D-pad |
| `bin/libcarplay_hook.so` | Native hook (ARM/QNX), `LD_PRELOAD`ed into `dio_manager`: pulls the artwork out of iAP2, decodes it, writes a 170×170 PNG |
| `install.sh` | Runs **on the unit**; does the whole install, idempotent |
| `uninstall.sh` | Runs on the unit; puts everything back |
| `custom.sh` | M.I.B. entry point — finds the payload on the card and calls the above |

Exact sizes, worth checking after any download:

```
bin/libcarplay_hook.so       124917
bin/coverart_hook.jar         29048
bin/dpad_hook.jar             11108
bin/librgd_hook.so           188215
bin/rgd_hook.jar             158617
bin/maneuver_render          130135
bin/flag_atlas.rgba          917504
bin/rgd_blank.png                310
bin/shaders/main.vert.bin       1060
bin/shaders/main.frag.bin      11132
bin/shaders/fxaa.vert.bin        472
bin/shaders/fxaa.frag.bin       2112
```

**On Windows, download this repository fresh** (clone again, or Code → Download ZIP).
Earlier copies were checked out with CRLF line endings and every script in them fails on
the unit. `.gitattributes` now pins LF, but only for new downloads — the
[repair recipe](https://github.com/chefranov/mhi2-au37x-carplay/wiki/Installation#before-you-copy-anything-windows-line-endings) is
more work than re-downloading.

## Install

Over a network cable, with the USB-Ethernet adapter installed from the M.I.B. menu:

```sh
ssh root@172.16.250.248 'mount -uw /mnt/app; mkdir -p /mnt/app/root/carplay'
scp -O -r bin install.sh uninstall.sh root@172.16.250.248:/mnt/app/root/carplay/
ssh root@172.16.250.248 'sh /mnt/app/root/carplay/install.sh'
```

Then reboot. Do not stage the files under `/tmp` — it holds no directories on this unit.
To install everything
*except* route guidance, run the installer as `RGI=0 sh /mnt/app/root/carplay/install.sh`;
to force the sport cluster layout (not normally needed), as
`SPORT=1 sh /mnt/app/root/carplay/install.sh`.

From an M.I.B. SD card: put `custom.sh` at `/mod/custom.sh` and the rest of the
repository at `/mod/carplay/`, then run `Advanced Settings → Run Custom Script` and
reboot. To leave route guidance out on this path, put an empty file named `NO_RGI`
next to `install.sh` on the card; to force the sport cluster layout, one named `SPORT`.

Full walkthrough of both, plus a scripts-free manual install and the list of everything
that gets changed: **[Installation](https://github.com/chefranov/mhi2-au37x-carplay/wiki/Installation)**.

Upgrading is just running `install.sh` again — no need to uninstall first. Coming from a
release before 2026-10-01, the installer also deletes the pre-drawn maneuver frames it
used to put in `/mnt/app/eso/hmi/lib/rgd_frames/`, which frees about 90 MB on that
partition. Nothing reads them any more.

## Verify

The native hook is quiet unless you ask it to talk — `/tmp` on this unit is RAM, and a
log that grows for the length of a session eats it. Turn it on, then plug in an iPhone
and play something with artwork:

```sh
touch /mnt/app/carplay_verbose
slay -f dio_manager          # picked up on the next start
cat /tmp/carplay_hook.log
```

A healthy run ends with the cluster asking for the picture:

```
[INF] artwork decoded 600x600 (3 ch) -> 170x170
[INF] published coverart: crc=b5012bdf
[CoverArtProvider] requestPicture entryID=0 sourceType=0 known=true
```

If that last line never appears, check the module 17 adaptation. Delete the marker file
when you are done; warnings and errors are logged either way. What the other lines
mean, and what to do when they are missing:
**[Verifying and troubleshooting](https://github.com/chefranov/mhi2-au37x-carplay/wiki/Troubleshooting)**.

Route guidance needs no marker to check: start a route in Apple Maps or Google Maps
with the phone plugged in, and the maneuver appears in the cluster tile within a second
or two. Two logs, both always on:

```sh
cat /dev/shmem/rgd_hook.log      # the native hook, small and bounded
cat /dev/shmem/rgd_render.log    # the renderer
```

Both live in RAM, which means they are lost when the ignition goes off — deliberately,
because the renderer writes a line or two per second and `/mnt/app` is flash. Read them
with the car still on, or keep them on flash for a drive you want to study:

```sh
touch /mnt/app/carplay_log_persist   # then reboot; logs move to /mnt/app/*.log
rm /mnt/app/carplay_log_persist      # back to RAM
```

The renderer's log says where each shader came from, and that is the line to look at if
the tile stays empty:

```
render: main.frag from blob /mnt/app/eso/hmi/lib/shaders/main.frag.bin (11132 bytes, status 0)
```

## Turning route guidance off

It does not have to be uninstalled to be switched off:

```sh
ssh root@172.16.250.248 'mount -uw /mnt/app; touch /mnt/app/rgd_disable'
```

Reboot, and the unit behaves as if the patch were not there: the cluster keeps its own
navigation, nothing of ours is loaded into `mm-ipod` or the HMI, and the renderer is not
started. Delete the file and reboot to turn it back on. The other two patches are
unaffected either way.

The same file also stops the renderer while the unit is running: its supervisor checks
for it between restarts, so the next time it would come back up it exits instead.

While it is on, CarPlay owns the maneuver tile whenever a route is running on the phone,
and the built-in navigation gets it back the moment that route ends or is cancelled.

## Uninstall

```sh
ssh root@172.16.250.248 'sh /mnt/app/root/carplay/uninstall.sh'
```

or create an empty `/mod/carplay/UNINSTALL` on the card and run the custom script again.
Reboot afterwards.

## Credits

Derived from [luka-dev/mib2q-carplay-rgi](https://github.com/luka-dev/mib2q-carplay-rgi) —
the HMI class-patch pattern and the cover-art pipeline come from there. That project
targets the Cinemo/Qualcomm MHI2Q stack; the native side here is a rewrite for the HARMAN
iAP2 stack these AU37x units use.

Thanks to [Mich795](https://github.com/Mich795), who took this build apart and sent back
a version of their own. Several fixes in the 2026-09-03 release came from reading it: the
session boundary that stops the first cover of a session being discarded as a duplicate,
dropping a fetch when the phone has already moved to another track, retrying a fetch whose
bytes have not arrived yet, and reusing artwork already built.

Route guidance follows the same lineage: the BAP protocol work, the cluster-side
constants and the Java half's shape are Luka's, and so is the renderer — the maneuver
geometry, the lane panel's layout rules and the destination-flag atlas shipped here are
his work. `bin/maneuver_render` is a port of it to C99 for this stack, drawing through a
client window the cluster composites rather than seizing a stock displayable.

Earlier releases of this repository could not run that renderer at all: the driver on
these units has no shader compiler. They drew the arrows ahead of time instead and
played them back as ~5400 pictures. Shipping the shaders compiled removed that
detour.
