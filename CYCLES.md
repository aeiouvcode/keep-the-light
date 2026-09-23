# KEEP THE LIGHT - improvement cycles

## Competitor frame (cycle 2)
Ground truth: the Antikythera dive piece (three.js journey, museum reveal).
Genre rivals: itch.io lighthouse-keeper jam games, "A Short Hike"-scale
exploration loops, cinematic three.js micro-experiences.

Where we lose, honestly:
1. SOUNDSCAPE WAS SILENT. Rain and wind beds were synthesized but never
   started - only thunder one-shots and interaction sfx played. The dive
   reference lives on its atmosphere; we shipped half of ours unplugged.
2. Pane quest is collect-5-of-the-same. Rivals (Short Hike) give each pickup
   its own vignette. Ours at least places panes in distinct spots (oil store,
   sea cave, scaffold gap) but they all read as identical glowing discs.
3. No mid-game vista payoff. The tower is a corridor until the roof; the
   genre's best moments are earned views partway up.
4. Footstep hiss had raw noise highs (harsh on phone speakers - his standing
   audio bar: low levels, softened highs).
5. Security/privacy: clean. Zero network calls, zero external assets, no
   tracking, no storage writes. Single-threaded export, no COOP/COEP needs.
   Rivals that phone home lose here; we don't.

Fixed this cycle (cycle 2, sound + polish):
- rain (-13dB), wind (-17dB), and a new deep surf swell (-20dB, mostly
  lowpassed noise, slow 0.55Hz heave) now loop from boot, title screen on.
- Footstep highs softened: noise cut 0.16->0.15 amp and blended 60/40 into
  the lowpassed tail; the 75Hz body thump unchanged.

## Cycle 3 (shipped)
Pane identity: each of the 5 panes now owns a sea-glass hue
(amber/teal/rose/violet/green) across its shard glow, its HUD pip
(silhouette at 22% alpha until collected, full hue on pickup) and the
lens facet it refits into during the relight. Verified on phone-portrait
frame: five distinct diamonds read clearly at 390px.

Next cycle candidates (in priority order):
1. Level-2 balcony vista: a door gap in the tower wall at the second landing
   framing moon + sea (cheap: wall segment skip + railing).
2. Title-screen motion: slow camera drift on the stair column.
3. Pause menu with controls recap (Esc / touch button).
4. Per-pane pickup chime ladder tied to hue order (currently count-based).

## Cycle 4 (shipped)
- Window depth bug (pre-existing): the sky and rain quads sat at z=-0.08/-0.04,
  OUTSIDE the wall face - every window in the game rendered as a black hole
  since cycle 1. Moved inside the frame tunnel (+0.06/+0.10, matching the
  door-panel convention). All four windows now show sky.
- Gallery window at the second landing (th=6.0): 1.9x width, dedicated
  tex_vista() - big haloed moon, moonlit sea with reflection shimmer, stars
  (design verified via pixel replica), plus an additive moon-spill pool on
  the stair.
- Pause: ESC toggles a PAUSED card (controls recap, RESUME button); world,
  oil and thunder freeze while paused - verified oil frozen at 82 then
  resuming. Touch pause button still pending.
- Title camera drift existed since the polish patch (orbit + bob) - backlog
  item closed with no change needed.

Known gap (next cycle): the follow camera hugs the keeper, so wall features
pass at the frame's left edge - the vista is seen by looking around, not
handed to the player. Consider a subtle camera pull-out near th=6.0, or a
small landing. In-game vista framing capture still pending; verified so
far by texture replica + geometry/depth reasoning + window-frame presence.

## Cycle 5 (shipped)
- Vista composition: the cycle-4 texture was verified rendering but composed
  for a full view the camera never shows (moon at 26% height, sea at the
  bottom third). Pixel-sampled the in-game window: it was rendering navy
  sky all along, reading as a hole. Recomposed tex_vista for the visible
  mid band (moon at 46%, brighter sky/sea/stars), brightened the narrow
  windows' sky and moved their moon into view.
- Camera: in the gallery zone (|th-6.0|<0.85) the follow camera eases its
  trail from 0.5 to 1.05 rad so the window enters the frame instead of
  passing at the edge.
- Verification tooling lesson: headless swiftshader fps makes wall-clock
  screenshot timing useless; trace-triggered single screenshots from a
  polling loop (never from inside the console handler - that kills the
  CDP session) are the reliable pattern.

Known gap (next cycle): the keeper still blocks the window's center at the
closest approach; the moon reveals at the left of the frame. Consider
swinging to -1.3 rad or placing a landing.

## Cycle 6 - 2026-09-23 ~17:10 IST - PASS
Built: bay-window rotation (+0.38 rad, reads architectural at gallery left), camera look-target
blend toward the wide window inside the gallery zone (zw weight, lerp 0.55), pause chip "II"
top-right wired to toggle_pause with a direct hit-test in _input (mouse + touch), pips nudged to -160.
Failed then fixed: the pause chip was a GUI Button - synthetic click at its rect never fired
(desktop mouse). Replaced with the same manual hit-test pattern the JUMP button uses; verified
zr-pause.png shows the PAUSED card (center avg 230,220,203 vs 57,36,42 running) and resume returns.
Verify3 full loop: WON ok. pck 73,600 bytes (clean, no screenshot bloat).
Note: window work stops here per backlog note; next cycles = per-pane chime ladder, landing idea.
