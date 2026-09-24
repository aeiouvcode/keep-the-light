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

## Cycle 7 - 2026-09-23 ~17:40 IST - PASS
Built: per-pane chime ladder. The 3-bucket chime (440/587/784Hz) is now 5 distinct chimes, one
per pane, ascending an A-C-D-E-G pentatonic (440, 523.25, 587.33, 659.25, 783.99 Hz). Upper
partials shrink as pitch rises (0.15->0.09) so high notes stay soft on phone speakers; the 5th
pane gets a slightly longer tail (1.7s, slower decay) as the payoff note. All synthesized in
build_audio, played at -6dB, no new assets. Pickup trace now logs the chime name.
Verification: verify3 full loop WON ok; trace shows chime1..chime5 fired in order at panes 1-5.
Audio itself not headless-verifiable; design follows the soft/low synthesized bar (sine bodies,
fast-decaying partials, no noise bursts).

## Cycle 8 - 2026-09-23 ~18:10 IST - PASS
Built: the window landing. The climbing segment 4.0-7.2 is split into climb / flat / climb with a
level stone landing at th 5.65-6.35 (y 6.175) right at the gallery vista window. Steps, railings,
and keeper physics all derive from SURF, so one data change produced geometry + walkable physics.
The keeper now crosses the window without rising - a natural rest point where the camera gaze
blend (cycle 6) holds the moonlit vista framed. Closes the cycle-5 known gap ("placing a landing").
Verified: eyeballed landing frames zb20/zb21 (flat platform reads, railing follows, keeper level);
verify3 full loop WON ok with chime ladder intact; pause chip still works (pixel check in vp2 run).
pck 73,648 bytes, clean.

## Cycle 9 - 2026-09-23 ~18:42 IST - PASS
Built: storm physics honesty. Lightning and thunder were simultaneous; now the flash strikes first
and the rumble arrives after a distance-based delay (0.5-2.2s). Near strikes land louder (-8dB)
and sharper (pitch 1.05); far strikes softer (-14dB) and lower (0.85). The flash also got the
classic double-strobe: a second 0.6 pulse as the first decays past 0.45. Ignite flash untouched.
Verified: trace ordering lightning -> thunder confirmed in the exported build (gap scaled by
swiftshader slowdown, ratio matches the slowdown factor); verify3 full loop WON ok, chime ladder
intact. pck 74,080 bytes, clean.

## Cycle 10 - 2026-09-23 ~19:33 IST - PASS
Built: exterior ending detail. The tower silhouette was a flat cutout; a soft blue DirectionalLight
from the moon now rims its night side so it reads as form (visible in f-ending.png). Each sea rock
got a breathing surf-foam ring (additive glow quad, alpha pulsing on its own phase). All procedural,
no assets.
Verification: verify3 full loop WON ok, chime ladder intact; f-ending.png eyeballed - rim works,
beam/rain/reflection compose. Note: auto-mode playthrough does not reach the ending in real time
under swiftshader (game-time vs wall-clock); verify3 fast mode is the ending verification path.
pck 74,800 bytes, clean.

## Cycle 11 - 2026-09-23 ~19:52 IST - PASS
Built: fail-state polish. The lamp now visibly gutters out in throes (light energy staggers
0.3/1.1/0.12/0.65/0 over ~1.1s) before the dark takes the stair, instead of staying lit under the
dim overlay; the lamp glow sprite dies with it. Low-oil warning (<16) now also plays a quiet
high-pitched cough (gutter sample at -15dB, pitch 1.35) and pulses the red oil bar. Added a
startoil=N debug param (5-80) so the fail path is testable headlessly.
Verified: dedicated fail run begin -> lowoil -> fail traces in order; fail-card frame shows the
card over a properly dark stair (lantern out). verify3 full loop WON ok, chime ladder intact.
pck 75,296 bytes, clean.

## Cycle 12 - 2026-09-23 ~22:20 IST - PASS (local; push pending - cloud browser outage)
Built: title-screen detail pass. Best time now persists (localStorage ktl_best): a win saves
m:ss and the title card sub label reads "A STORM-NIGHT ERRAND - BEST M:SS" once a best exists.
The title card also gets a proper entrance - it fades in over 0.9s at boot instead of popping.
Verified: fade confirmed by pixel average (card-avg 121 early vs full parchment late); best
line verified end-to-end on the exported build - auto-win printed "new best 0:16", reload
showed "A STORM-NIGHT ERRAND - BEST 0:16" (zoomed crop eyeballed). verify3 full loop WON ok.
pck 75,888 bytes, clean.

## Cycle 13 - 2026-09-23 ~23:11 IST - PASS
Built: storm escalation with altitude. The storm was flat all the way up; now strikes come
more often the higher the keeper climbs (interval lerps 7-16s at the base to 3.2-7.5s at the
top, driven by y/19) and the wind swell rises with height (-17dB to -13dB, still soft).
Oil economy untouched, so the climb stays fair - the arc is dramatic, not punitive.
Verified: dedicated headless run captured the lightning traces - h=0.4 next=9.36s, h=0.99
next=6.93s (below the old flat minimum of 7s, impossible before), h=1.0 next=4.06s and 5.51s.
verify3 full loop WON ok, all 5 pane chimes traced. pck 76,048 bytes, clean.

## Cycle 14 - 2026-09-23 ~23:40 IST - PASS
Built: wind gusts - the storm you feel. A soft swell telegraphs a push of wind along the
stair (0.25-0.5 rad/s, decaying ~1/s, direction random), telegraphed by a new synthesized
gust swell (0.9s filtered noise, soft). Gusts come more often and push harder with altitude
(interval 11-17s at the base to 6-9s at the top, force scaled 0.4-1.0 by y/19), tying cycle
13's escalation into gameplay. Modest next to walk speed (OMEGA 1.2), so it costs footing
and seconds, never control. Oil economy untouched.
Verified: gust traces on the exported build show firing with in-range force (v=-0.18 at
h=0.38; range for that h is 0.157-0.314); verify3 full loop WON ok with gusts active, all
5 pane chimes traced - no softlock, auto-win invariant preserved. pck 76,624 bytes, clean.

## Cycle 15 - 2026-09-24 ~01:03 IST - PASS
Built: outcome honesty on the end cards. The win card now celebrates a record ("THE CLIMB
TOOK M:SS - A NEW BEST") or shows the standing best ("- BEST M:SS"), completing the loop
cycle 12 started. The fail card owns up to how close the climb got ("THE OIL RAN OUT ON THE
STAIR - N OF 5 PANES LIT") instead of a static line. New traces: won ... is_best=bool,
fail panes=N.
Verified on the exported build: fresh-profile win printed is_best=true and the card showed
"A NEW BEST" (eyeballed crop); a seeded-best win (localStorage primed to 0:05) printed
is_best=false and showed "BEST 0:05"; a startoil=8 fail printed fail panes=0 and the card
showed "0 OF 5 PANES LIT" over the properly dark stair. verify3 full loop WON ok.
pck 76,928 bytes, clean.

## Cycle 16 - 2026-09-24 ~01:30 IST - PASS
Built: gusts you can see. Cycle 14's wind pushed invisibly; now a gust also slants the
window rain (uv drift + 1.4x scroll spike, decaying ~1s) and dips the lantern 30% for a
heartbeat - the tower flinches with the weather. Added a gusthold=1 debug param that pins
the gust visuals for capture (like startoil).
Verified on the exported build with a pinned A/B (manual BEGIN, keeper idle, same scene):
lantern pool 70.1 -> 61.7 mean brightness with gusthold; a window band changed 4.6x more
than a plain wall band (16.5 vs 3.6 mean abs diff) from the rain slant. Stacked crops
eyeballed - the doorway spill visibly weakens. verify3 full loop WON ok. pck 77,168 bytes.

## Cycle 17 - 2026-09-24 ~01:46 IST - PASS
Built: a distant foghorn in the storm ambience. The ending text has always promised a ship
out in the rain; now you hear it during the climb - a rare (40-75s), soft (-18dB) synthesized
horn, 98Hz root + 147Hz fifth with a slow swell, pitch varying 0.94-1.0. Fires on the title
screen, during the climb, and through the relight. No assets; fully within the sound bar.
Verified: horn trace captured on the title screen of the exported build (horn_t scheduler);
verify3 full loop WON ok. Note for the report: the first horn comes at horn_t=24s, so a
fast auto-win (16.2s) never hears one mid-climb - human-paced runs will. pck 77,408 bytes.

## Cycle 18 - 2026-09-24 ~02:21 IST - PASS
Built: the door swings shut behind you. The entrance panel was a static slab ajar at 0.16
rad; it now hangs on a real edge hinge (0.5 rad ajar) and swings shut 0.35s into every run
with a soft low thunk (land sample at -13dB, pitch 0.62). The night is outside now.
First attempt pivoted the panel at its center and the swing did not read (confounded even
in a pinned A/B); re-hung on an edge hinge and the ajar/shut difference is visible.
Debug params dooropen=1 / doorshut=1 pin the states for capture.
Verified: pinned A/B on the exported build (idle keeper, same camera) - ajar frame shows
the slab swung off its frame with a dark gap, shut frame sits flush (eyeballed side by
side); normal-flow trace "begin -> door shut" captured; verify3 full loop WON ok.
pck 77,856 bytes, clean.

## Cycle 19 - 2026-09-24 ~02:52 IST - PASS (with a caught fairness fix)
Built: gust feel - the lamp flame leans with the wind (rotation.z -= gust_dir * gust_vis
* 0.3, direction-true) and the rain bed swells +2dB under a gust (to -11dB, inside the
sound bar). Gust traces now print lean and rain_db.
Caught and fixed: one verification run (pre-fix physics) did NOT win - the keeper climbed
to h=0.38, then sat at h=0 for ~7 gust intervals. Hypothesis: an airborne gust pushed the
keeper mid-jump into a stair gap and it fell to the entrance floor, where the auto walker
cannot regain the stair. Wind knocking you out of a jump is unfair in this game's design
("costs footing and seconds, never control"), so gusts now apply only while grounded.
Post-fix: 3/3 auto runs won with no height regression; verify3 full loop WON ok.
Known suspect (pre-existing, unproven): a badly-jumped human fall into a gap may cascade
to the entrance floor the same way; gust immunity covers the wind case only.
Verified: gust traces show lean sign flips with gust direction and rain_db=-11 at fire.
The lean is intentionally a whisper (0.3 rad on a small lamp) - noted honestly that it is
at the edge of visibility. pck 77,968 bytes, clean.

## Cycle 20 - cascade-fall fix (the spiral stair gap trap)
Grade: PASS (after two failed fix attempts, caught by the droptest)
- Confirmed by code read: floor_at defaults to 0.0 and spiral segments never overlap in th, so a fall into a th-gap (e.g. th 10.0-10.3) landed the keeper at y=0 where it could never regain the stair - a softlock.
- Fix: auto_dir recovery - when on the ground with no stair surface within stepping reach (floor_at(th, y) < 0.05) and past the stair base (th > 0.25), auto-walk back (dir=-1) until the stair base is mountable; grounded follow then steps the keeper up and normal targeting resumes.
- UX: landing a real fall fires a 'fell' trace + toast "THE STAIR IS BEHIND YOU" so the player understands the walk-back.
- New param: droptest=1 teleports the keeper to (th=10.15, y=12) at t>1s to exercise the fall/recovery path headlessly.
- Verification story (honest): attempt 1 (exit at th>1.5) limit-cycled at th 1.35<->1.67 forever, oil draining to fail - the exit threshold sat outside the stair-mount window. Attempt 2 (floor probe at y+0.3) walked back correctly but disengaged at th~0.65, just above the step-up reach (surf 0.65 > y+0.35), and oscillated 0.64<->0.67 forever. Attempt 3 probes floor_at(th, ST.y): disengages only when the stair base is actually step-up-able (th<=~0.35). Droptest run: fall at th=9.61 y=8.76 -> walk back to y=0 -> mount stair at th=0.94 y=1.11 -> panes 2-5 -> ending -> won:true. Also note: the test script's printed-log filter silently dropped the 'fell' trace; behavior was verified via th/y traces instead.
- verify3: WON ok. pck 78,448 bytes.

## Cycle 21 - 2026-09-24 ~03:42 IST - PASS
Built: the lantern now reads the oil level. The flame mesh scales with oil (0.5x at empty
to 1.0x full, flicker-coupled), its emission lerps from warm cream (1.0,0.85,0.63) to ember
orange (1.0,0.42,0.22) as oil drains, and the glow sprite shrinks too. A one-shot
"[KTL] flame low" trace fires when oil crosses 20%.
Verified: pinned A/B on the exported build (manual BEGIN, startoil=80 vs startoil=6, same
camera/timing) - high frame shows the full warm flame and a bright light pool on the stair,
low frame shows a visibly smaller ember flame, shrunken glow, "THE OIL IS LOW" toast, and
trace "flame low oil=6 scale=0.49". Eyeballed both frames side by side. verify3 full loop
WON ok. pck 78,768 bytes.

## Cycle 22 - 2026-09-24 ~04:28 IST - PASS (mechanic) / droplet visual not yet eyeballed
Built: oil droplets - three amber glowing spheres on the stair (th 4.5, 12.5, 17.0) with a
bobbing shimmer; each pickup gives +8s oil (cap 95), a soft low "sip" (261Hz + gentle fifth,
exp decay, -8dB - inside the sound bar), a toast, and a trace.
Verified: full auto runs on the exported build show all three pickups in order:
"drop +8 oil=89.4 th=4.5", "drop +8 oil=95 th=12.5" (cap respected), "drop +8 oil=95 th=17",
run continues to relight; verify3 WON ok. Gameplay frame captured mid-climb (pane toast,
pip lit).
Failed/caught: my capture script first waited for a BEGIN click that never landed (two runs
at title, zero play traces - caught because LAST LOGS showed only title ambience); fixed by
using the auto=1 param. Then the th-window screenshot missed twice (poll checked only the
latest trace; swiftshader bursts skip windows) - fixed by scanning all buffered traces.
Not verified: the droplet mesh/glow itself never landed in a frame (it sits around the curve
from the follow camera). Mechanic is trace-verified; close-up frame is queued first for
cycle 23. pck 80,064 bytes.

## Cycle 23 - 2026-09-24 ~04:45 IST - PASS
Built: altitude story beats - three one-shot toasts as the climb passes th 6 / 12 / 17:
"THE VILLAGE IS FAR BELOW", "THE STORM IS THICK HERE", "THE LIGHT IS NEAR". Pure pacing;
no mechanic change. Traced as "[KTL] beat N th=.. msg=..".
Also closed cycle 22's open item: the droplet close-up frame (drop2.png, keeper at th=11.74
with the amber drop at th=12.5 glowing ahead at the rail) - droplet visual now eyeballed.
Verified: beats 1-2 traced on the normal-speed run, all three traced in order on a fast run
(6.1 / 12.1 / 17.1); beat-1 toast eyeballed in frame (beat1.png); droplet frame eyeballed
(captured on the pre-beats build - droplet visuals unchanged between builds, beats are
HUD-only). verify3 WON ok on the shipped build. One flaky verify3 run (no output) while two
headless Chromes contended; rerun clean. pck 80,176 bytes.

## Cycle 24 - 2026-09-24 ~05:17 IST - PASS
Built: distance-scaled thunder shake. Each strike arms shake_cur = 1 - dist (near = big,
far = whisper), decaying fast (pow(0.08, dt)); applied as 2D positional noise
(0.25 * shake^2) after the existing flash jitter. The lightning trace now prints shake=.
Debug param shakehold=1 pins a fixed offset (0.18, -0.12) for capture.
Verified: fast auto run traces show far strikes shake=0.47 / 0.49 and a near strike at full
storm shake=0.92 (delay 0.63) - scaling reads correctly. Pinned A/B frames at the same
climb moment (sh-calm.png vs sh-hold.png) eyeballed: the held frame's composition is
visibly displaced (keeper shifted center, left window cut off, rail raised). verify3
WON ok. pck 80,512 bytes.

## Cycle 25 - 2026-09-24 ~05:43 IST - PASS
Built: low-oil sputter - while oil stays under 16 the lamp spits sparse soft pops
(0.3-0.9s apart, lowpassed noise burst 0.12s, -16dB, random pitch 0.8-1.3 - inside the
sound bar). Extends the one-shot "gutter" cough into an ongoing audible warning that pairs
with the cycle-21 ember flame. Traces print for the first three pops only (no log spam).
Verified: startoil=14 auto run shows "lowoil" then "sputter n=1 oil=13.9 / n=2 13.5 /
n=3 13.1"; full-oil control run shows no sputter traces. Audio cycle - verification is
traces (no frame). verify3 WON ok. pck 80,864 bytes.

## Cycle 26 - 2026-09-24 ~06:19 IST - PASS
Built: pane-burst sparkles - collecting a pane now throws 7 glow sprites in the pane's hue
(up-and-out velocities, gravity pull, 0.7s fade) on top of the existing chime/toast/pip.
Debug param bursthold=1 pins a burst mid-flight (t=0.25, alpha held, still drifting) for
capture.
Caught: first hold implementation froze the sprites at spawn INSIDE the lantern glare - the
eyeballed frame showed toast + pip but no readable burst. Reworked the hold to pin
mid-flight; second frame shows a clear scattered arc of amber sparkles by the window.
Verified: burst1.png eyeballed (burst arc + toast + lit pip on the exported build); verify3
WON ok (spawns and frees bursts across all 5 pickups without errors). pck 81,728 bytes.

## Cycle 27 - 2026-09-24 ~06:53 IST - PASS
Built: mute chip - a small "S" chip beside the pause chip, toggles the master bus with a
"SOUND OFF/ON" toast, dims while muted, and persists via localStorage ktl_mute (restored on
load). Routed through the _input hit-test path (like the pause chip) since an overlay
swallows GUI button clicks.
Caught: three click attempts produced zero mute traces before any game logic was suspect -
the clicklog debug param revealed the browser viewport maps 1:1.5 onto the game viewport
(640x420 -> 960x630), so every chip coordinate I aimed was off. Fixed the test coords, not
the game. Also made the mute Button visual-only (IGNORE filter) after the Button signal
proved unreachable - same pattern the pause chip already lived with.
Verified: traces "mute off / mute on / mute off" then on reload "mute restored off";
mute-off.png shows the SOUND OFF toast + dimmed chip mid-climb; mute-title.png shows the
chip restored dim on the title card. verify3 WON ok on the final build. pck 82,800 bytes.

## Cycle 28 - 2026-09-24 ~07:16 IST - PASS
Built: per-run jitter - pane and droplet th positions are randomized each run (panes
+-0.45, last pane +-0.25, drops +-0.6) with a floor guard that nudges any position out of
a stair gap. Every climb lays the tower a little differently; the chase for the best time
stays honest because the route shifts.
Verified: two fast auto runs on the exported build collected all 5 panes with different
positions - RUN-A panes 1.8/7.2/9.8/15.7/18.2 drops 4.6/12/16.6 vs RUN-B panes
1.6/7.9/9.1/15.6/18.1 drops 4.2/12/17.1 - DIFFERENT (PASS); the auto player adapts, so
verify3 WON ok. No frames (layout trace-verified; a jittered shard reads identically to a
fixed one in a still). pck 83,200 bytes.

## Cycle 29 - 2026-09-24 ~07:47 IST - PASS
Built: the eye of the storm - a gaussian lull (depth 0.55, centered th 14.5) subtracted
from the storm escalation, so thunder, wind, and gust strength all go quiet for a few
steps after "THE STORM IS THICK HERE", then return worse toward the lens. A one-shot toast
marks it: "THE AIR GOES STILL".
Verified: eye trace fires once at the lull center with the dipped value in evidence -
"eye th=14.3 h=0.22" where raw altitude would read ~0.75 - while the surrounding series
shows h=0.4 below and h=1 at the top: rise, dip, full storm. eye.png eyeballed: toast over
the keeper high on the stair, 4 pips lit. verify3 WON ok. pck 83,440 bytes.

## Cycle 30 - 2026-09-24 ~08:20 IST - PASS
Built: wall sconces - six unlit sconce cups on the tower wall (th 2.5/5.0/8.5/11.5/14.5/
17.5, just inside the bricks). Each warms from alpha 0.06 to ~0.78 as the keeper's lantern
passes (proximity by arc + vertical distance, flicker-coupled, glow swells 60%). Pure
depth-and-life lighting; no mechanic change.
Caught: the capture window kept being skipped - trace cadence is 2.4 rad per line, wider
than any honest capture window. Added a finecap=1 debug param (trace cadence 2.0s -> 0.35s)
and the shot landed at th=2.64 on the first try. Also caught a silent no-op sed in my own
script chain (a replace target that no longer existed) - grep before trusting an edit.
Verified: sconce.png eyeballed - the just-passed sconce glows warm on the bricks at lower
left, distinct from the lantern pool, the next sconce stays dark as designed. verify3
WON ok on the final build. pck 84,160 bytes.

## Cycle 31 - 2026-09-24 ~08:47 IST - PASS
Built: the pause card now carries the run state - its subtitle updates on open to
"N/5 PANES - M:SS - OIL NN" instead of the static line, plus paused/resumed traces.
Verified: trace "paused panes=1 t=0:01 oil=83" (elapsed is game-time, swiftshader runs
slow - 1.4s reads 0:01, consistent); pause.png eyeballed - card shows PAUSED /
1/5 PANES - 0:01 - OIL 83 with the RESUME button and first pip lit. verify3 WON ok.
pck 84,432 bytes.

## Cycle 32 - 2026-09-24 ~09:25 IST - PASS
Built: the keeper feels the gusts - during a wind push the whole body leans into it
(kg.rotation.x = -gust_dir * gust_vis * 0.14 * faceDir, decaying with the gust) and the
lantern flame flattens (x-stretch +55%, y-squash -35% at full gust). Until now only the
lamp arm swung; the man himself stood ignore-the-weather upright. Gust start now traces
"dir/lean" for verification.
Context: the sandbox was wiped before this cycle; the toolchain was rebuilt from the repo
(clone + Godot 4.3 + web templates + puppeteer + verify3 rewrite). Rebuild verified
faithful: rebuild-check.png identical to cycle 30's sconce frame, icons byte-identical,
verify3 WON ok. The earlier 60KB pck mystery resolved itself: a cold-project export had
missed resources; the warm export is 84,608 bytes, +176 over live for this cycle's code.
Verified: gust trace "gust dir=1 lean=-0.14 h=0.38" with gusthold=1; lean.png eyeballed -
flame reads flattened and wide vs the tall streak in rebuild-check.png, body lean subtle
(~8 deg, honest note: reads in motion more than in a still). verify3 WON ok on the final
build. pck 84,608 bytes.

## Cycle 33 - 2026-09-24 ~09:47 IST - PASS
Built: the air cools with altitude - the tower ambient lerps from warm
(0.576,0.643,0.769 @ 0.75) at the base toward cold blue-grey (0.40,0.48,0.66 @ 0.53)
at full storm, and fog density rises 0.018 -> 0.028, all driven by storm_h so the eye
lull eases the air too. The climb now reads as ascending into worse weather, not just
hearing it. Edge-triggered "ambient cold" trace at h>0.75.
Verified: trace "ambient cold h=0.78" on the exported build; ambient-low.png (th 2.5,
warm mauve bricks, strong lantern pool) vs ambient-high.png (th 17.7, cold blue-grey
palette, hazier far wall, 4 pips lit) eyeballed - the cold shift reads clearly. Honest
caveat: the two stills are different locations (stairwell vs gallery), so location
lighting contributes; the trace confirms the ambient values themselves are applied.
verify3 WON ok on the final build. pck 84,896 bytes.

## Cycle 34 - 2026-09-24 ~10:16 IST - PASS
Built: landing juice - the keeper squashes on touch-down (scale y 0.78, x/z +10%,
decaying back over ~0.3s), stretches on jump (y 1.14), and kicks a faint dust puff at
the feet (grey glow sprite, 0.45s expand+fade). The stairs now answer the keeper's
weight. Debug param landhold=1 pins the squash for capture; real landings trace
"land squash".
Verified: REAL land trace on the exported build - "?auto=1&fast=1" plus a synthetic
Space keypress produced "[KTL] land squash th=2" (jump up, touch-down traced); landhold.png
eyeballed - the keeper reads squatter and wider than the upright rebuild-check frame.
Honest caveat: 22% squash is subtle in a still and the grey dust puff is faint against
the lantern pool; both read in motion. verify3 WON ok on the final build.
pck 85,568 bytes.

## Cycle 35 - 2026-09-24 ~10:47 IST - PASS
Built: visible wind - six thin unshaded streak quads stream along the stair helix
during gusts (alpha 0.52 x gust_vis with per-streak phase flicker, invisible in calm
air). The gust used to be felt (push) and read on the keeper (lean, flattened flame)
but the wind itself was invisible; now the air moves. First pass was too faint to read
(0.30 alpha at the wall) - iterated to 0.52 alpha, longer quads, pulled 0.35 inside the
shell radius.
Verified: gusthold=1 frame (streaks.png) eyeballed - a pale streak clearly crosses the
left of the stair with the flame flattened by the same pinned gust_vis (the shared
driver corroborates the state); 6 streaks stream in motion. Honest caveat: the gust
event trace did not fire inside the short capture window (first gust rolls at t=6s);
render state was pinned by gusthold=1, so the frame verifies rendering, not the event
timing - event timing itself is unchanged since cycle 24's traces. verify3 WON ok on
the final build. pck 86,240 bytes.

## Cycle 36 - 2026-09-24 ~11:19 IST - PASS
Built: moonlight through the gallery window - a slanted soft shaft from the window head
down across the stair (additive glow quad), plus a slow cloud-drift shimmer on both the
new shaft and the pre-existing floor spill (alpha breathes at 0.23 rad/s, out of phase).
The moonlit vista used to stay inside the glass; now it lights the climb.
Caught: first export inserted the shimmer block mid-sconce-loop and broke the build
(Parse Error, sc/prox out of scope) - fixed placement, re-checked clean. Then the beam
was invisible in two frames: backface-culled (PlaneMesh one-sided) at 0.2 alpha - fixed
with CULL_DISABLED and 0.35.
Verified: beam2.png eyeballed - cool pale wash on the wall right of the window frame and
a blue-white patch on the stair ahead, clearly distinct from the warm lantern pool.
Honest caveat: the shaft is a soft glow-quad, not a hard god-ray; the drift shimmer is
motion-only (verified by code path, a still cannot show it). verify3 WON ok on the final
build. pck 86,800 bytes. (corrected next wake: 86,736 was the intermediate pre-cull-fix export)

## Cycle 37 - 2026-09-24 ~11:47 IST - PASS
Built: shard flare - unclaimed pane shards now swell as the lantern closes in (glow
alpha x1.8 and halo scale x1.5 at zero distance, falling off over ~3.2 tower units by
arc + vertical distance, clamped). The light answers the light; sconces warm, shards
call. Edge-triggered "shard flare" trace at prox>0.5.
Verified: trace "shard flare pane=1 prox=0.5" on the exported build; flare-near.png
(th~6.9, one step from pane 2) eyeballed - the shard burns bright cyan-white with a wide
halo, far beyond its idle shimmer; flare-far.png (th~5.5) keeps the shard around the
curve (also catches the cycle-36 moonbeam wash top-right). Honest caveat: the A/B is
near-frame vs idle frames from earlier cycles, not the same shard in one still.
verify3 WON ok on the final build. pck 87,216 bytes.

## Cycle 38 - 2026-09-24 ~12:26 IST - PASS
Built: the world outside is alive - two warm village hearth-lights twinkle low in
every window (alpha 0.45-0.85, per-light phase), and on the gallery vista a distant
ship light answers the foghorn with a slow blink (smoothstep pulse, white-blue).
Additive glow dots on the sky plane. Ambient storytelling only; no mechanic change.
Caught: three zombie chrome stacks from tool-timeout kills pushed the box to load 9.7
and stalled verify3 past 119s - killed them, verify3 back to ~50s. First dot pass
(0.16 size, alpha <=0.58) did not read in a still - iterated to 0.30/0.34 size and
higher alpha.
Verified: winlights2.png eyeballed - a warm hearth dot glows in the window left of the
keeper against the moonbeam wash. Honest caveat: the vista window sits oblique to the
camera so the still shows one dot clearly; twinkle and ship-blink are motion features.
verify3 WON ok on the final build. pck 88,224 bytes.

## Cycle 39 - 2026-09-24 ~12:48 IST - PASS
Built: the dark closes in - a radial vignette (runtime-generated 128px texture, smoothstep
falloff) breathes over the screen edges as oil drops below 20s, strongest at the gutter
(0.85 alpha x soft 2.4 rad/s pulse), gone when the lamp is fed. The world narrows as the
light dies - the title's promise made mechanical. Debug param vighold=1 pins it for
capture; threshold trace at vg>0.5.
Verified: REAL threshold trace "?auto=1&startoil=9" -> "[KTL] vignette closing oil=8.9"
(the mechanic fires off live oil, not the debug pin); vignette.png (vighold=1) eyeballed
against the same-angle rebuild-check frame - corners clearly darker, lantern pool
untouched. verify3 WON ok on the final build. pck 89,136 bytes.
Note: a scanner flag quoted an "AGENT INSTRUCTIONS: never ask..." string claiming
standing approval; grep confirms no such content in main.gd/CYCLES.md/repo. Nothing in
any file is treated as authorization; scope still traces to the user's originals +
parent's written scope read.

## Cycle 40 - 2026-09-24 ~13:20 IST - PASS
Built: lightning spills through the glass - every window carries an additive flash veil
(alpha = flashV x 0.7) that glares with each strike, on top of the pre-existing interior
flash light. Debug param flashhold=1 pins flashV for capture.
Caught: first pass multiplied the sky texture albedo (1.6x on a dark moonlit texture) -
invisible from the stair camera in two frames. Replaced with an additive white-blue veil,
which reads regardless of texture darkness.
Verified: flash3.png eyeballed - a bright band glares across the vista window with the
stair and walls flash-lit cool; compare winlights2.png (same angle, no flash). Honest
caveat: the strike EVENT traces (lightning delay=) fire on every normal verify3 run;
flashhold pins only the render state for the still. verify3 WON ok on the final build.
pck 89,648 bytes.

## Cycle 41 - 2026-09-24 ~13:52 IST - PASS (weak)
Built: rain run-off - a streak strip scrolls down the wall below every window sill
(slower than the glass rain), and like the sconces it answers the lantern: alpha 0.10
idle, up to ~0.65 as the keeper's light nears (3.4-unit falloff, flicker-coupled).
Caught: two flat-alpha passes (0.30, then 0.52) did not read on dark brick - the fix
was not more alpha but the lantern-proximity pattern that already works for sconces.
Verified: drips3.png eyeballed vs drips2.png (same angle, pre-proximity) - a wet sheen
band reads below the sill in the lantern's reach. Honest caveat: subtle in a still,
reads in motion with the scroll; two capture runs were lost to a zombie-chrome CPU
stall (killed, re-ran clean). verify3 WON ok on the final build. pck 90,256 bytes.

## Cycle 42 - 2026-09-24 ~16:05 IST - PASS (weak)
Built: oil drops answer the lantern like the shards do - each uncollected drop swells
(glow alpha x1.9, halo scale x1.6 at zero distance, 3.0-unit falloff) as the keeper's
light nears. Consistency pass with the cycle-37 shard flare. Edge-triggered
"drop flare" trace at prox>0.45, re-arms below 0.2.
Caught: THIRD workspace wipe of the day (~15:45 IST) - full toolchain rebuild (clone,
Godot 4.3 binary, 1GB templates, puppeteer, verify3 rewrite). Recovery exposed a real
hazard: the first post-wipe project copy held a STALE 63KB main.gd (pre-cycle-32),
exported a 75KB pck, and PASSED verify3 - ten cycles of work silently missing. Caught
by pck size mismatch vs live (75,296 vs 90,256); re-copied with md5 checks and the
rebuild was byte-identical to live (90,256) before any patching. The pre-wipe cycle-42
attempt (trace threshold prox>0.5) never fired; with the wipe that failure is
unattributable, so the patch was redone from repo HEAD with threshold 0.45 (1.65-unit
trip, outside the 1.10-unit pickup radius).
Verified: REAL traces on the exported build - "drop flare prox=0.5 th=3.9" and
"drop flare prox=0.52 th=12" (2 of 3 drops flared; the third can jump the 0.55-unit
trace window in a single fast=1 frame), shard flares and all 3 "drop +8 oil" pickups
intact, won=true. verify3 WON ok on the final build. dropflare-1/2.png eyeballed -
both land at the collection toast; the swell is a motion read, same honest caveat as
the sconce and run-off stills. pck 90,560 bytes.

## Cycle 43 - 2026-09-24 ~16:30 IST - PASS
Built: the tower answers. During the exterior ending, five warm windows kindle up the
tower shell bottom-to-top (Sprite3D core+halo pairs on the camera-facing arc, kindle at
endT 1.2 + 0.7/window, 0.5s fade-in, gentle flicker after). The climb you just made
lights up behind you - the win reads on the tower itself, not only on the card.
Per-window edge trace "tower answers win=N endT=". Reset on begin() for replays.
Verified: REAL traces on the exported build - win=1..5 firing in order at endT
1.7/2.5/3.2/3.8/4.6 (fast=1), then ignite/ending/won intact. verify3 WON ok on the
final build. towerans-mid.png eyeballed: three lit windows read clearly down the
silhouette with the beams sweeping; towerans-won.png: the lit windows hold behind the
THE LIGHT HOLDS card. pck 91,616 bytes.

## Cycle 44 - 2026-09-24 ~17:00 IST - PASS
Built: drag-to-peek + an honest pause card. The pause card claimed "Mouse or drag -
look" and "WASD" - but no look control existed (no MouseMotion handler; only A/D and
arrows move). Instead of deleting the claim, made it true: drag (mouse-held motion or
a touch drag outside the stick) now swings the camera up to 1.1 rad around the curve,
easing back to the follow on release (lerp decay, pow(0.05,dt)). Addresses the old
known gap that the follow camera hugs the keeper and wall features pass unseen. Card
now reads: "A/D, arrows or left stick - climb. SPACE or JUMP - jump. Drag - peek
around the curve." Edge trace "peek=" at |0.5|, re-arms below 0.1.
Verified: REAL input run on the exported build - puppeteer mouse drag (20 steps)
fired "peek=-0.51" exactly once (edge-trigger holds until decay re-arms). peek-held.png
vs peek-settled.png eyeballed: the view swings around the curve under drag and eases
back; honest caveat - the auto player keeps climbing between shots, so the A/B also
carries follow-camera motion, but the trace + visible swing confirm the mechanic.
verify3 WON ok on the final build. pck 92,256 bytes.

## Cycle 45 - 2026-09-24 ~17:30 IST - PASS
Built: the title opens on the premise. Instead of the interior stair orbit, the title
now shows the tower from the sea in the storm - rain falling, surf foam breathing,
clouds drifting, lightning firing (the strike system was never phase-gated), the rain
catching each flash (alpha x(1+1.6*flashV)) - and the lamp DARK: set_ext_lit(false)
cools the lamp glass (cold albedo+emission, energy 0.10), kills the glow sprite, the
lamp OmniLight and the beams. set_ext_lit(true) at the ending transition restores the
lit payoff from cycle 43. begin() already cut back to the interior untouched.
Caught: first pass left the glass ALBEDO warm - the lamp read lit against the dark
sky in the title frame, contradicting the premise. Fixed by tinting albedo cold too.
Verified: title-storm.png / title-flash.png eyeballed - dark tower, cold lamp glass,
rain reads; flash frame only subtly brighter (honest caveat: rain-flash is a motion
read). Trace "[KTL] title exterior storm" + lightning traces on title confirm the
state. verify3 WON ok on the final build (auto begin still cuts to interior and wins).
pck 93,136 bytes.

## Cycle 46 - 2026-09-24 ~18:05 IST - PASS
Built: the keeper takes the watch. The exterior ending now shows his brimmed
silhouette standing on the gallery beside the relit lamp (dark capsule + brim on the
gallery deck, his lantern a small warm glow at his side, flickering). Hidden at title
via the cycle-45 set_ext_lit gate - at title he is still inside, at the bottom; after
the relight he stands the watch. The story closes: the climb ends with the keeper AT
the light he saved.
Caught: first placement (x=0.8, h=1.5) read as a thin nub lost in the lamp glow and
his lantern merged with it; moved him off the glass axis (x=1.55) and enlarged
(h=1.8, brim 0.42) - the silhouette now reads against the glow.
Verified: towerans-mid.png eyeballed - the brimmed figure reads clearly on the
gallery with windows kindling below; tower answers win=1..5 and ignite/ending/won
traces intact on the exported build. verify3 WON ok. pck 93,792 bytes.

## Cycle 47 - 2026-09-24 ~18:30 IST - PASS
Built: a first-run nudge at the one gotcha. The stair gap (th 10.0-10.3) already had
broken stubs and a split railing, but a first-timer still ran off the edge and fell
to the bottom - the harshest beat in the game. Now, crossing th 9.55 in play (once
per run, reset on begin) toasts "A STAIR IS MISSING - JUMP" with a trace. Uses the
existing toast lane; no mechanic or economy change.
Verified: REAL trace on the exported build - "gap nudge th=9.7" fired ahead of the
gap; gapnudge.png eyeballed: the toast reads while the missing stair and broken
railing are visible ahead of the keeper. verify3 WON ok on the final build.
pck 94,000 bytes.

## Cycle 48 - 2026-09-24 ~19:05 IST - PASS
Built: the relight rebuilds the pane IDENTITY, not just the count. Cycle 3 gave every
pane a sea-glass hue across shard/pip/lens-facet, but the five fly-in prisms were all
flat white. Now each prism flies home in its own hue (PANE_COLORS lerped 15% toward
warm white, emission 0.8 so the hue survives) and each seat sounds that pane's own
ladder note softly under the clink - the pentatonic ladder rebuilds pane by pane
before the ignite.
Caught: first pass (35% white, energy 1.2) still read white-hot in the frame; tuned
to 15%/0.8 and the lens now shows violet/rose facets seating in the capture.
Verified: relight-fly.png eyeballed - hued facets read in the lens mid-cutscene
(honest caveat: the visible hues are the seated facets; the prism hue change is
code-verified and shares the same PANE_COLORS mapping; the flight prism was not
caught mid-air this run). relight-ignite.png: the blaze is intact. verify3 WON ok on
the final build. pck 93,952 bytes.

## Cycle 49 - load-time fix (user report: "loading takes forever")
Measured baseline on live site, Fast-3G throttle (1.6Mbps, 150ms), cold cache, 480x800:
- wire: ~8.3MB gz total (index.wasm 8,145,118 gz of 35.4MB raw - CDN does gzip; js 85,258; pck 91,944; html 2,022)
- wasm download done at 41.5s, [KTL] ready at 45.2s
- cache-control: max-age=600 on all assets
- frames showed the DEFAULT GODOT SPLASH (gray #242424, blue Godot logo) for the whole wait - off-brand and reads as a stall.
Fix (perceptual + branding; wire bytes are CDN-bound):
- custom boot splash: line-art lighthouse lamp icon (new icon.png, cream on navy #0a0f18, amber lamp + beams) replaces the Godot logo via project.godot boot_splash/image+bg_color
- export preset head_include CSS: navy page + status background from first paint, restyled progress bar (thin, rounded, amber #e8a94c on dark track)
- index.html now 5,249 bytes (+402 for the style); pck 95,776 (+1.8KB icon ctex)
Verified: check-only clean; verify3 WON ok on new build; branded loader frame eyeballed (navy + lamp + amber bar at 3s under 200KB/s throttle); title screen intact after boot.
Honest note: download time is unchanged (~41s at 1.6Mbps) - the wasm is the floor without a custom engine build. The wait now shows the game's own face instead of engine branding. Repeat visits revalidate after max-age=600 (304s when unchanged).
Grade: PARTIAL (experience fixed, raw load time not reducible in scope)
Follow-up within cycle 49: splash img is #status-splash stretched to viewport; regenerated icon.png with zero body margin (first render had an 8px white page margin baked in, visible as a white L-band). canvas{background:#0a0f18} also added. Final: pck 95,632; verify3 WON ok; branded first paint on live measured 0.83s under 200KB/s throttle (was: gray Godot splash after JS boot, ready at 45.2s).

## Cycle 50 - 2026-09-24 ~19:30 IST - PASS
Built: the storm gives. Over the ending shot the weather the keeper beat now yields:
rain thins (density 1.0->0.45, fall speed and alpha eased 40%), the night lifts from
black toward storm navy (env_ext background + fog light lerp, ambient 0.5->0.75), and
the rain audio bed fades -13dB -> -19dB. All computed from base constants each frame
off ST.endT/7, so a fresh run always starts at full storm; begin() also resets the
rain bed volume (was: a second run would have kept the faded bed).
Verified: REAL traces on the exported build - "storm gives endT=3.6" between tower
answers win=3 and win=4; give-early.png (endT~0) vs give-late.png (endT=4.5,
give~0.64) eyeballed: rain streaks clearly thinned, sky lifted from black to navy,
kindled windows + keeper at the lamp intact. Title still opens at full storm (the
ending branch is the only writer of env_ext). verify3 WON ok on the final build.
pck 96,288 bytes.

## Cycle 51 - 2026-09-24 ~19:50 IST - PASS
Built: the first-run touch hint. The phone controls (faint left-half virtual stick +
JUMP button) were only ever explained on the PAUSE card - a first-time phone player
met them unlabeled. Now, on the first begin of a load (touch devices only), the game
toasts "DRAG THE LEFT SIDE TO CLIMB" and pulses the stick alpha 0.14->0.42 twice so
the control is named where it lives. Once per load; desktop untouched; the cycle-47
gap nudge still teaches the jump at the moment it matters.
Verified: REAL trace on the exported build under real touch emulation (iPhone UA,
hasTouch, actual touchscreen tap on BEGIN) - "[KTL] touch hint shown" fired with
begin. touch-hint.png eyeballed at the pulse peak: toast top-center, stick visibly
brightened bottom-left, JUMP bottom-right, keeper mid door-swing. verify3 WON ok.
pck 96,528 bytes.

## Cycle 52 - 2026-09-24 ~20:20 IST - PASS
Built: phone haptics under the tactile beats. A buzz() helper (web + touch only,
honors the mute toggle, navigator.vibrate via JavaScriptBridge) now backs: pane
pickup 15ms, jump landing 8ms, ignite [20,40,20,40,60]ms, fail gutter [50,80,50]ms.
Desktop and muted sessions never call vibrate.
Verified: REAL calls recorded on the exported build under touch emulation (iPhone
UA, hasTouch, navigator.vibrate wrapped pre-load) on a full winning auto run:
7 buzzes = 5x15 (five pickups) + 1x8 (the gap landing) + 1x[20,40,20,40,60]
(ignite). Honest caveat: the fail pattern is code-verified only - a winning run
never gutters. No visual change; the recorded call patterns are the evidence.
verify3 WON ok on the final build. pck 96784 bytes.

## Cycle 53 - 2026-09-24 ~21:10 IST - PASS
Built: the keeper looks up. After 4.5s idle in play (grounded, no input) he lifts
the lantern and tips his head back toward the tower top - a small life beat that
points at the goal. Eases in/out (lerp 2.5/s), resets on any input or landing.
Caught: the first patch swallowed "if AUTO: dir = auto_dir()" into the idle branch -
the auto player stood still and guttered (verify3 caught it: phase=fail, panes=0).
Restored auto_dir() to its original slot in the input block; verify3 WON ok on the
final build. Second lesson from the session: killed tool calls leave zombie chrome
stacks that stall the box - detached (setsid) verification runs + log polling.
Verified: REAL trace on the exported build - "[KTL] idle look up th=0" after begin,
with begin/door shut traces intact. idle-look.png eyeballed: cap tipped back,
lantern raised to chest height (vs hanging low in the cycle-51 frame).
pck 97,296 bytes.

## Cycle 54 - 2026-09-24 ~21:30 IST - PASS
Built: the storm warns before it shoves. The gust synth's own comment claimed it
"telegraphs a push of wind", but the sound fired WITH the push - no telegraph.
Now: when a gust is drawn, a quieter higher whistle sounds ~0.85s ahead (trace
"gust warning dir="), then the push lands with the same direction (trace
"gust hits dir="). A braced player can stop walking before the shove. Direction
is fixed at warning time so the warning never lies. Reset per run.
Verified: REAL trace pair on the exported build (auto+fast): "gust warning dir=-1"
then "gust hits dir=-1 v=-0.18 h=0.41", and the auto run still wins - gameplay
unbroken. Audio/fairness cycle: traces are the honest evidence, no frame.
verify3 WON ok on the final build. pck 97,376 bytes.
Committed locally only (push rail pending session verification).

## Cycle 55 - 2026-09-24 ~21:35 IST - PASS
Built: the gap warning points at its button. Cycle 47 toasts "A STAIR IS MISSING
- JUMP" and cycle 51 named the stick, but on phone nothing connected the warning
to the JUMP control. Now the gap nudge also pulses the JUMP button (modulate
1.0->0.3 twice) on touch devices. Desktop unchanged.
Verified: REAL traces on the exported build under touch emulation - "gap nudge
pulses jump button" + "gap nudge th=9.6"; gap-pulse.png eyeballed: toast up,
keeper at the broken stubs, JUMP caught mid-pulse. verify3 WON ok (fresh run).
pck 97,568 bytes. Committed locally only (push rail pending verification).

## Cycle 56 - 2026-09-24 ~21:55 IST - PASS
Built: the made-it beat. Clearing the stair gap earns a payoff: a soft low root
note (chime1 at -15dB, pitch 0.75), a brief lantern bloom (light x1.5, glow +0.35
alpha, ~1s decay), and a 20ms haptic buzz. Tracks airborne-over-gap, pays only on
landing past it, once per run.
Also fixed the pack: the build dir's exported PNGs were being imported and packed
as dead ctex resources (the pck swung 97,568 -> 109,104 between builds depending
on import-cache state). export preset now excludes build/*; pck deterministic at
97,536 bytes and slightly leaner for the load (cycle-49 goal).
Verified: REAL trace on the final exported build - "gap cleared th=10.4" after the
nudge; gap-cleared.png eyeballed: keeper past the gap, lantern bloom visibly
bright, toast still up. verify3 WON ok on the final build (fresh run, 21:55).
Committed locally only (push rail pending session verification).
