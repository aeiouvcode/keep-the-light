
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


## Cycle 12 - 2026-09-23 ~22:20 IST - PASS (pending final verify3)
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
verify3 WON ok on the final build. pck 0 bytes.


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


## Cycle 57 - 2026-09-24 ~22:20 IST - PASS
Felt: pickups register on the meter. Collecting an oil drop now pulses the
matching pip on the HUD meter (quick 1.6x scale + warm brighten, ~0.35s tween
back). Small earned feedback for the core loop's main verb.
Built: tween on ui.pips[i] modulate+scale fired from the pickup path; trace
"[KTL] pip pulse i=N" per pickup.
Verified: REAL traces on the final exported build - "pip pulse i=0..4" across
the auto player's five pickups, run WON. verify3 WON ok on the final build
(fresh run, 22:24). No still frame this cycle (screenshot job failed,
shot:false) - pulse is 0.35s and trace-verified instead.
pck 97,808 bytes (deterministic after build/* exclude).
Committed locally only (pck push blocked: upload-widget storage request fails
for this session; text files pushed via web editor to e101b1a).


## Cycle 58 - 2026-09-24 ~23:10 IST - PASS
Built: the balcony arch (backlog #1, reworked). The tower now opens to the
storm at the second landing (th=7.6, y=7.6 flat): a tall full-height arch
framing the moonlit sea (tex_vista reused portrait), a rain sheet scrolling
in the opening (joined to win_rain so it gusts with the rest), a Juliet rail
across the lower half, and a cool moon-spill pool on the landing boards. The
camera's gallery ease-wide now also covers the balcony landing
(zw = max(gallery, balcony bump)), so the arch is handed to the player, not
just passed at the frame edge.
Process note (honest): first build was floor-height and keeper-width - four
captures (hold pin, peek both ways, forced-camera diagnostic) showed the
keeper eclipsing it / sitting past the frame edge; a forced-camera capture
proved the geometry WAS built and placed correctly (trace "balcony built at
(1.75,7.62,6.75)"), so the fix was compositional: arch raised to 4.2m with
the vista centered +2.3 above the landing, clearing the keeper's head. New
debug param balconyhold=1 pins the keeper at the landing for captures (same
pattern as gusthold/landhold).
Verified: REAL trace on the final exported build - "[KTL] balcony th=7.56"
fired crossing the landing; balcony-a/b climb-past frames (phone-portrait
480x800) show the arch's moonlit mass (max-brightness @ cluster) center-frame
above the keeper on approach, spill bright on the landing. verify3 WON ok on
the final build (fresh run, 23:11). Audio: none added (foghorn/ship already
live there).
pck 99,952 bytes.
Committed locally; text files pushed via web editor, pck held for the
Cloudflare pair-deploy.


## Cycle 59 - 2026-09-24 ~23:25 IST - PASS (audio-only)
Felt: the climb buys exposure. The wind bed now lifts and thins with altitude
(+0..+3dB and pitch 1.00->1.08 across y=0..19), layered on the existing
storm_h swell, so the last flights of stairs sound as exposed as they look.
Base and title screen are untouched (alt factor is 0 at y=0); the ending keeps
the top's keener air, which fits the lamp's exposed perch.
Built: one altitude term in the wind loop's volume/pitch (computed live each
frame, so begin() needs no reset); one-shot traces at y=5/10/15 for evidence.
Verified: REAL traces on the final exported build - "wind alt y=5 db=-15.1
alt=0.27 pitch=1.02", "y=10.6 db=-13.1 alt=0.56 pitch=1.04", "y=15.2 db=-13.3
alt=0.8 pitch=1.06" (db rides storm_h moment-to-moment; alt and pitch climb
monotonically), run WON. Audio-only cycle - no frame; traces are the evidence.
Sound bar kept: synthesized only, +3dB over a -17dB bed, no new highs (pitch
shift is 8% on filtered noise).
pck 100,400 bytes. verify3 WON ok on the final build (fresh run, 23:23).
Committed locally; text files pushed via web editor, pck held for the
Cloudflare pair-deploy.


## Cycle 60
Critique: a returning player gets the same cold title as a stranger - the game stores
best_time() in localStorage (ktl_best) but never uses it outside the win card. The
premise card reads "the lamp is out" to someone who lit it last week.
Built: the title remembers. When ktl_best exists, the title sub-line reads
"A STORM-NIGHT ERRAND - BEST CLIMB M:SS" instead of plain "A STORM-NIGHT ERRAND";
first visits and desktop/headless (best_time()==0) are untouched. One guarded branch
after the title card build, trace "[KTL] title remembers best=M:SS".
Verified: verify3 WON ok (regression). Harness: seeded localStorage ktl_best=192.4,
reload -> trace best=3:12, frame shows the remembered sub; control pass with the key
removed -> no remembers trace, sub plain. Frames: c60-title-best.png, c60-title-plain.png
(480x800 phone portrait). Honest note: the seeded best is synthetic (192.4s), not a
real prior win - the write path (win_run -> localStorage) is unchanged and already
covered by earlier win-card verification.
Grade: PASS.


## Cycle 61 - split-pack deploy (mechanics, not a game change)
CF migration paused: github.io stays the live home and the pck must deploy normally
again, but the token bridge is banned (credential rule), the upload widget is dead on
any size, and the web editor is text-only. Proven-route fix (per Astronaut/suikei):
the pck ships as base64 text parts. index.pck split into 4 x 25,140-byte chunks (each
a multiple of 3 so the b64 strings concatenate cleanly), pushed as index.pck.b64.0-3.
index.html gained a split-pack loader: window.fetch is wrapped before the Engine is
created; a request for index.pck is answered from the reassembled bytes (fetch parts
-> atob -> Uint8Array -> Response). If every part 404s (local dev), it falls through
to the real index.pck, so the local loop is unchanged; a partial part failure throws
honestly instead of silently loading a stale pack.
Verified: with build/index.pck renamed away from the server root (a plain fetch would
404), verify3 ran a full auto win on the patched shell - chimes=5 won=true, WON ok -
so the game booted and completed on bytes assembled from the parts alone. Roundtrip
b64 decode == original pck asserted at split time.
Grade: PASS (deploy unblocked without touching the credential rule).


## Cycle 62 - the escalation ladder (deep cycle for the 7 AM push)
Critique: the game is a one-shot errand. Once you have won, you have seen everything;
there is no reason for a second climb. The highest-impact gap is structural: no loop.
Built: the storm remembers a streak. Consecutive wins raise the storm I-V; a fail
takes the streak. Persistence in localStorage (ktl_storm, 1-5). Per level L:
storm base +0.08*(L-1) on storm_h (the storm starts stronger at the door), oil
80-4*(L-1) (80/76/72/68/64), gust cadence x(1-0.1*(L-1)). Title names the awaiting
storm ("STORM III - BEST 3:20", or "STORM III - THE SEA TESTS YOU AGAIN" without a
best); a HUD chip names the storm past I; the win card appends "STORM IV AWAITS" or
"THE HIGHEST STORM HELD" at V; the fail card owns the reset: "THE STORM TAKES THE
STREAK". Debug param storm=N overrides the level for tests and never touches the
stored streak; startoil= keeps priority over level oil.
Failed then fixed: (1) storm= parse off-by-one (substr mst+7 -> mst+6) made every
override read as I; caught by pass A asserting L=3. (2) A pre-existing SECOND
title-sub writer in _ready overwrote my build_hud block with the older
"A STORM-NIGHT ERRAND - BEST M:SS" format - it also means cycle 60's title frame
was rendered by that older writer, not the c60 block (identical visible text, so
c60 could not tell them apart; user-visible behavior was right throughout). Removed
the old writer; single source of truth, re-verified with frames.
Verified (final build, pck 102,320): verify3 WON ok (L=1 regression). Pass A storm=3:
L=3 oil=72 gustx=0.8, win, ktl_storm untouched (override guard). Pass B storm=5:
L=5 oil=64 WON (hardest level winnable), "THE HIGHEST STORM HELD". Pass C seeded 2:
win -> ktl_storm=3, card "STORM III AWAITS". Pass C2: title remembers storm=III.
Pass D standing fail at L=3: reset trace, ktl_storm=1, fail card "THE OIL RAN OUT ON
THE STAIR - 0 OF 5 PANES LIT - THE STORM TAKES THE STREAK". Frames eyeballed: STORM
III title, STORM II chip on the win frame, streak fail card (480x800). Harness note:
the auto player wins even with startoil=5, so the fail test uses manual BEGIN and a
standing keeper - the harness D-pass limitation is logged, not hidden.
Grade: PASS.


## Cycle 63 - telegraph the storm before the first climb
Critique: the escalation ladder (c62) gave the game a loop, but a returning player
cannot FEEL the higher storm until they are already climbing. The stakes should be
visible and audible in the first ten seconds: the title is the storm's stage.
Built: (1) Title weather now scales with the awaiting storm: rain fall speed and
streak alpha and surf foam alpha ride rainx = 0.85 + 0.15*L (1.0 at I, 1.45 at IV,
1.6 at V). The title block computes title_lvl once via storm_level_get() and traces
it. (2) Begin toast: starting a climb above storm I toasts "STORM III - THE SEA IS
HIGHER" (suppressed when the first-run touch hint is pending, so a brand-new touch
player never gets two teaching texts at once). Foam scaling applied to the TITLE
phase only; the ending phase keeps its own weather (the storm is meant to ease
there - deliberate, not an omission).
Failed then fixed: the first patch script died pre-write on a non-unique anchor
(the foam alpha line exists in BOTH the title and ending phases); the assertion
saved an unscoped double edit. Re-ran with a 4-line title-context anchor.
Verified (final build, pck 102,752): verify3 WON ok (L=1 regression). Split-pack
boot verified locally with index.pck hidden - the game runs purely off the 4 b64
parts. Traces: storm=1 title "title storm lvl=1 rainx=1"; storm=4 title "title
storm lvl=4 rainx=1.45"; storm=3 begin "storm toast lvl=3"; streak trace intact
("title remembers storm=III"). Frames eyeballed: L1 vs L4 title rain (L4 visibly
denser/brighter streaks in a still) and the begin toast in-world at 480x800.
Harness note: first harness run had two string bugs of its own (matched 'lvl= 4'
with a space; toast screenshot raced browser close) - game code was right, the
harness was wrong; re-ran corrected.
Grade: PASS.


## Cycle 64 - the storm has a voice (audio character per level)
Critique: the escalation ladder (c62) and the visual telegraph (c63) tell the
returning player the sea is higher - but the game's richest channel, its
synthesized soundscape, still sounds identical at storm I and storm V. The storm
should SOUND heavier before the first step.
Built: apply_storm_audio() shapes the three ambient loops by the awaiting/active
level: wind pitch 1.0 -> 0.90 (1.0 - 0.025*(L-1), a deeper bed - softer highs, on
the sound bar), wind volume -17 -> -15.4 dB, rain -13 -> -11 dB, surf -20 -> -18
dB. Gust one-shots deepen 3%/level on top of the c62 storm_h volume scaling.
Applied at begin (reset_run) and re-checked on the title every 0.5s (throttled
localStorage read) so a streak change is heard the moment the title shows it.
No new samples synthesized - pitch/volume shaping of the existing kit only.
Failed then fixed: the title re-arm replaced c63's one-shot title_lvl block with a
change-detect (title_lvl != storm_level_get()); first harness expected the rise
trace after a win WITHOUT clicking through - but KEEP IT AGAIN goes straight to
_on_begin, there is no title return post-win. Second harness clicked too early
(card still tweening in); with a 2.5s settle the click lands and the rise
verifies. Game code was right twice; the harness was wrong twice. Logged, not
hidden.
Verified (final build, pck 103,440): verify3 WON ok. Split-pack boot with the pck
hidden. Traces: storm=1 "storm audio lvl=1 windp=1 rainv=-13 surfv=-20"; storm=4
"lvl=4 windp=0.925 rainv=-11.5 surfv=-18.5"; seeded-2 begin "lvl=2 windp=0.975";
win at 2 then KEEP IT AGAIN -> "storm audio lvl=3 windp=0.95 rainv=-12 surfv=-19"
+ "storm level L=3 oil=72 gustx=0.8" + "storm toast lvl=3". Audio is
trace-verified; there is no still-frame delta (honest note). Win card frame from
this build shows STORM III AWAITS.
Grade: PASS.


## Cycle 65 - the capstone: storms held, and the sea quiets
Critique: the escalation ladder had no ending. Beat storm V and every future run
is storm V forever - the loop plateaus instead of breathing. A loop that never
resolves quietly stops being a reason to come back.
Built: beating storm V banks the run into a permanent tally (ktl_held in
localStorage) and resets the awaiting storm to I. The win card becomes "THE
HIGHEST STORM HELD - THE SEA QUIETS"; the title sub carries the tally forever
("A STORM-NIGHT ERRAND - BEST 3:20 - 1 HELD", or "STORM III - BEST 3:20 - 2 HELD"
mid-streak). The loop now breathes: rise I->V, hold the highest storm, the sea
quiets, begin again with a mark that persists. Debug runs never bank: the whole
capstone block is guarded by STORM_OVERRIDE == 0 (setters were already guarded;
the trace + counter compute are guarded too, so a storm=5 test win prints no
phantom "storm held total=").
Failed then fixed: no code failures. One harness check-string bug of my own
(matched 'total= 1' with a space; the trace joins without it) - the substance was
green on every assertion. Logged, not hidden.
Verified (final build, pck 104,304): verify3 WON ok (L=1 regression). Split-pack
boot with the pck hidden. Pass A (override guard): storm=5 debug win -> card "THE
HIGHEST STORM HELD" with NO "SEA QUIETS", no held trace, localStorage
held=null/storm=null. Pass B (seeded storm V, real win): card "... - THE HIGHEST
STORM HELD - THE SEA QUIETS", "storm held total=1", "storm level next=1",
localStorage ktl_held=1 ktl_storm=1. Pass C (fresh load): "title remembers
best=3:20 held=1". Frames eyeballed: the capstone win card (STORM V chip) and the
quieted title carrying "1 HELD" (480x800).
Grade: PASS.


## Cycle 66 - the trophy row: one lit pane per storm held
Critique: the capstone tally (c65) lives only in a text fragment. A held storm is
the game's highest achievement - it deserves a mark in the game's own visual
language, not another word.
Built: a centered row of small lit diamond pips on the title card, one per banked
storm, cycling the five sea-glass pane hues at 0.85 alpha with the HUD pips' 45
degree diamond turn. Inserted between the sub line and the body on the title card
only, capped at 10 (the sub text already carries the exact number). First visits
and zero-tally players see no row at all.
Failed then fixed: no code failures. First harness contaminated its own control:
all three passes shared one browser profile, so pass B (the zero-tally control)
read pass A's seeded ktl_held=3. Re-ran with incognito contexts per pass and an
explicit key-clearing control (remove, not just omit) - the standing
localStorage-flow lesson applied.
Verified (final build, pck 104,768): verify3 WON ok. Split-pack boot with the pck
hidden. Pass A (3 held): "title held pips=3", "title remembers best=3:20 held=3",
frame shows three hue-cycled diamonds. Pass B (control, keys cleared): no pips
trace, no remembers trace - a truly clean first-visit title. Pass C (1 held +
storm III): "title held pips=1", "title remembers storm=III held=1", frame shows
one amber diamond under "STORM III - BEST 3:20 - 1 HELD". Frames eyeballed at
480x800.
Grade: PASS.


## Cycle 67 - the calm sea reward (rain gentles, a lit ship drifts by)
The capstone gave keeping the light a tally; this gives the tally a weather.
When the keeper has banked storms and the sea sits at level I, the title night
itself thanks them: the rain gentles and a distant ship crosses the horizon.
Built: calm-sea state on the title (storms_held > 0 and storm level I). Rain
intensity drops to 0.8x via the existing rainx multiplier. The pre-existing
exterior ship (built for the ending) becomes visible and drifts left-to-right
across the horizon band left of the card at z=-340, bobbing gently, its window
glow scaled 2.2x and a new mast-top navigation light added (same warm glow
texture). reset_run restores the ship's ending-choreography anchor, rotation,
and both glow scales. Debug: shipz=N overrides the distance.
Failed then fixed: first drift placement (z=-85/-95, x -55/-40) put the ship
off-frame - the unproject trace sat at (-21.8, 960.1). A z sweep (220/280/340)
mapped the horizon band, then a duplicate-ship bug surfaced: my drift block
collided with the pre-existing EXT.ship (var shadowing caught pre-write by
grep). Removed the duplicate; the drift reuses the original ship. Glow scale
1.5x at z=-340 was invisible in stills; 2.2x window + 1.6x mast light reads.
Verified (final build, pck 105,792): verify3 WON ok. Split-pack boot with the
pck hidden. Calm pass (held=2): "calm sea held=2", "title storm lvl=1
rainx=0.8", ship screen trace drifting (143,927) -> (193,934) backing-store px
over 30s. Control pass (keys cleared): no calm trace, rainx=1, ship hidden.
Frames eyeballed at 480x800: full title plus a 4x crop of the horizon strip -
the warm lit dot and faint hull smudge sit exactly on the horizon line.
Grade: PASS.


## Cycle 68 - the calm must be earned (fail-sea vs capstone-sea fix)
Cycle 67 shipped a flaw: the calm-sea reward triggered on held > 0 and storm
level I - but a FAIL at any level above I also resets the sea to I, so a keeper
who failed down from storm IV returned to the same gentled rain and lit ship
as one who banked the highest storm. The capstone's reward was being handed
out for failure. The fail card even says THE STORM TAKES THE STREAK; the sea
now agrees.
Built: ktl_calm provenance flag in localStorage. Set only by the capstone
branch (banking storm V, the existing STORM_OVERRIDE guard preserved) with a
"calm earned" trace. Cleared in fail_run when a fail takes the streak, with
"storm level reset calm_taken=N" trace. The title calm check now requires
level I + held > 0 + the flag. Failing AT level I keeps an earned calm (no
streak to take); winning off level I leaves the flag harmlessly set until the
sea rises (the level check closes the calm by itself).
Failed then fixed: no game-code failures. First export shrank the pck by
13.6KB - icon.png had been moved out with the stray-PNG sweep; it is embedded
in the pck, so restored it and re-exported (106,080). Then the fail harness
repeated the c62 lesson: auto=1 always wins even with startoil=5, so pass C
"failed" by winning (storm 3 -> 4, flag correctly untouched). Re-ran the fail
pass with a manual BEGIN click and no auto player.
Verified (final build, pck 106,080): verify3 WON ok. Split-pack boot with the
pck hidden. Pass A (held=2, flag=1, level I): "calm sea held=2", rainx=0.8,
ship drifting. Pass B (held=2, level I, NO flag): no calm trace, rainx=1, no
ship - the failed-down keeper sees an ordinary level-I night. Pass C (manual
begin, fail at storm III with flag=1): "storm level reset calm_taken=1",
ktl_calm reads 0, ktl_storm reads 1, fail card "THE OIL RAN OUT ON THE STAIR
- 0 OF 5 PANES LIT - THE STORM TAKES THE STREAK" (frame c68-fail.png). Pass D
(real capstone from stored storm V, no override): "storm held total=1 calm
earned", ktl_calm reads 1.
Grade: PASS.


## Cycle 69 - five storms, five nights (storm visual identity)
The escalation ladder made each storm harder but they all LOOKED like the same
night: level drove oil, gusts, audio and intensity, never the sky. The fantasy
says five seas; now each sea owns a night.
Built: apply_storm_identity(lvl), called on begin_run and on title level
change. A five-step tint palette (I indigo-neutral, II cold teal, III violet,
IV rose, V bruised ember) multiplies the tower and exterior environment
backgrounds and fog, the moon key light, every window sky quad (materials
collected at build), and the exterior moon + halo emissions (base colors
banked at build). The sky also darkens 7.5% per level - the storm eats the
sky. The ending's dawn lerp still overrides the exterior at the win moment,
and the title re-applies on the next level change, so no state goes stale.
Failed then fixed: first palette was too polite - the L1/L3/L5 title strip
barely differed. Strengthened tints ~1.5x and the dark factor 0.055 -> 0.075.
Second strip: storm V reads clearly (darker, ember cast); mid-levels stay
quiet on the TITLE (the tower blocks the moon there) but carry in-game, where
the violet III and ember V stairwells are unmistakable against the indigo I.
Verified (final build, pck 107,024): verify3 WON ok. Split-pack boot with the
pck hidden. Identity traces at title for storm=1/3/5 (tint + dark values
correct) and in-game at begin for storm=3 and storm=5. Frames eyeballed at
480x800: the L1/L3/L5 title strip, the storm-III violet stairwell, the
storm-V ember stairwell with the correct oil=64 budget on the HUD.
Grade: PASS (title mid-level subtlety noted honestly above).


## Cycle 70 - the storm breathes through the windows (proximity audio)
The wind, rain and surf beds were global: the storm sounded identical pressed
against an open window as sealed in the stair core. Windows are openings to
the weather; passing one should breathe.
Built: window positions banked at build (the four stair windows, th and y).
Each play frame, rain and surf bed volumes swell above their storm-level base
by keeper proximity to the nearest window (arc distance x R_SHELL plus
vertical gap, 5-unit range, squared easing, +4 dB cap on rain, +2.8 on surf).
Base volumes are stored in apply_storm_audio and restored on the title so the
swell never leaks out of a run. Throttled trace on each 0.5 dB change.
Failed then fixed: no failures. Grading note: the measured peak in the auto
run is +1.7 dB (the keeper passes below the window center), quieter than the
+4 cap by design's easing - a polite breath, kept as-is per the sound bar
rather than chasing decibels blind.
Verified (final build, pck 108,176): verify3 WON ok. Split-pack boot with the
pck hidden. 14 swell traces firing at exactly the four window thetas
(1.3-2.2, 5.8-6.8, 10.6-11.5, 14.7-15.0), max +1.7 dB, bounded under the cap;
on return to title the audio trace shows base volumes (rainv=-12, surfv=-19
at level III) - the restore works. Audio is trace-verified; no frame can show
it (a gallery-window pass frame was captured for context).
Grade: PASS.


## Cycle 71 - the lantern's contact shadow (and jumps that read)
No shadow work existed anywhere in the game: the keeper floated on the lit
stone, and with no real-time shadow casting (a deliberate perf choice for the
phone) there was nothing to anchor him or to judge jump height by.
Built: a soft contact shadow under the keeper - a flat-lying glow-texture
sprite in pure black, parked on the floor surface under him each frame
(floor_at, the same surface query the physics uses). It grounds him in the
lantern pool. On a jump it stays on the step below while he rises: the alpha
fades from 0.42 to zero across 2.6 units of height and the disc widens, so
airborne height reads at a glance - a play-feel improvement, not just polish.
Visible in play and the relight, gone at title and in the dark of a fail.
Failed then fixed: no code failures. The verification harness missed the
gap-jump frame - the phase traces print too slowly to catch a 0.7s jump
window, and the fallback shot landed late. Grounded payoff is frame-verified;
airborne behavior is verified by the jump math (vy 8.4, g 24, apex ~1.47 ->
alpha ~0.18 with the disc separated ~1.5 units below) and honestly logged as
not frame-captured.
Verified (final build, pck 108,512): verify3 WON ok. Split-pack boot with the
pck hidden. Grounded frame eyeballed at 480x800: the keeper stands anchored
on a dark elliptical pool inside the lantern light - compare cycle 69's
storm-V frame where his feet met bare bright stone.
Grade: PASS.


## Cycle 72 - the ship comes home in frame (2026-09-25, ~5:45 AM IST)
Grade: PASS (local; deploy pending at write time).
Finding: the win card says "Somewhere out in the rain, a ship sets her course for home" and the ending scene HAS the ship - she sails, the beam finds her, a bell rings, she turns for home - but she started at (-58,0,-105), ~50 degrees off the ending camera's axis, entering the frame only ~19s in, long after the card (6.5s). The ending's signature moment played off-camera: a bell at an empty sea.
Built: at the ending transition the ship now re-seats on a frame-crossing course (-4,0.1,-80), sailing the visible water from the first seconds; her cabin/masthead glows are strengthened (1.7/1.3) and a soft warm reflection glow (alpha 0.15) sits under her hull so the crossing reads on a phone. Per-run reset now also clears ship_turn/belled so repeat endings re-play the bell + turn. Added two traces: bell moment + mid-ending ship screen coords.
Verified: check-only clean; export 109,248B; verify3 WON ok; local harness (pck removed, loader reassembled from 4 parts) - "bell for the ship at screen (429,968) endT=3.3", "ending ship at screen (457,969) endT=4.1" (960x1600 backing = right-center at the sea line, in frame), won elapsed clean, no new console errors (the one p_pattern USER ERROR is pre-existing engine noise - A/B'd against the live cycle-71 build, same count: 1). Frames c72-ship.png (crossing reads: two warm lights + faint reflection on black water) and c72-bell.png (beam sweeping toward her) eyeballed PASS.
Also settled this cycle: storm-V oil budget audited with real numbers - 64 start + 24 (3 drops) + 25 (5 panes) = 113s vs ~16-20s optimal climb; healthy for humans by design, no patch. Low-oil signaling, thunder, storm-V win acknowledgment ("THE HIGHEST STORM HELD - THE SEA QUIETS") all audited as already present.


## Cycle 73 - the storm reaches the lamp room (2026-09-25, ~6:05 AM IST)
Grade: PASS (local verified; deploying).
Finding: the relight cutscene - the run's climax - played in a lamp room walled in dark brick (the tower wall cylinder spans y-1..25), with no sign of the storm the light is about to defeat. c72-relight.png showed the bare backdrop. A lighthouse lamp room is glass above the masonry; the storm should be waiting outside it.
Built: a night-sky band cylinder (r=6.94, flip_faces, y 19-25) with a new tex_lampsky() - deep storm gradient, horizon-glow low band, 70 stars, 26 slant-rain strokes; registered in tower.sky_mats so the c69 storm-identity tint applies per level. Plus a rain-streak cylinder (ADD, alpha 0.10, r=5.34) on the lamp glass itself. No moon (the vista owns it; a 360-degree band would multiply it).
Verified: check-only clean; export 110,256B; verify3 WON ok; local harness (pck removed, loader reassembled) at storm III: relight + ignite + won traces clean, tint trace (0.9,0.8,1.12) applied, no new errors (p_pattern is pre-existing engine noise). Frames: c73-relight.png (pre-ignite: glass drum, bronze mullions, violet storm-III night through the glass, stars + horizon band + rain slants; pane mid-flight) and c73-ignite.png (the drum blazes warm against the dark storm still visible at the edges) - both eyeballed PASS against the c72-relight.png before-frame (flat dark walls).


## Cycle 74 - phone chips double-fired + touch controls card (2026-09-25, ~6:15 AM IST)
Grade: PASS (local verified; deploy staged for next wake).
Finding 1 (real phone bug): tapping the pause or mute chip on a touch device fired the toggle TWICE - browsers emit a compatibility mouse click alongside every tap, and _input handled both InputEventScreenTouch and InputEventMouseButton chip hits. Harness caught it: one tap logged "paused" then "resumed" instantly - on a real phone the pause card would flash and vanish, and mute would bounce back. The fix dedupes both directions (event order varies): chip_tap_guard rejects any second chip hit within 0.6s and 40px, whichever event type arrives second. Care taken to keep the virtual-stick and jump elif chains intact (first restructure broke the stick chain; caught on read-back, fixed, rechecked).
Finding 2: the pause card's controls line was keyboard-only ("A/D, arrows or left stick... SPACE") - noise for the phone player. It now switches on is_touch: "Drag the left half of the screen - climb. JUMP - jump. Drag the right half - peek around the curve. Walk into a pane to take it."
Verified: check-only clean; export 110,960B; verify3 WON ok; touch-emulated harness (iPhone viewport, hasTouch): "controls card touch=true" traced at build, tap 1 = "paused" only, tap 2 = "resumed" only (was paused+resumed per tap before the fix), errors none. c74-pause-touch.png eyeballed: card shows the touch controls text over the door scene with stick + JUMP visible. Desktop mouse path unaffected (guard only dedupes within the same-tap window).


## Cycle 75 - the tower groans in high storms (2026-09-25, ~6:29 AM IST)
Grade: PASS (audio-only cycle, trace-verified - no frame, by design).
Finding: storms III-V share one voice (louder rain/wind/surf, tint, gusts). The tower itself - the thing being pushed - was silent. "THE STORM IS THICK HERE" had no structural counterpart.
Built: a low structural groan (1.7s synth: 86Hz pitch sagging to 64Hz with a 9Hz shudder, weak 2.7x partial, squared-sine envelope, low-pass feedback keeps it dark; plays at -21dB with pitch wobble). Fires only during play at storm III+, on a 16-32s timer that tightens 12%/level; the timer always runs so entering level III mid-arc never bursts. Debug: groanhold=1 arms a 0.5s first fire.
Verified: check-only clean; export 111,520B; verify3 WON ok. Harness (pck removed, loader reassembled): L3+hold -> "tower groans lvl=3 t=0.6" then "t=15.6" (natural cadence in the expected 12-24s window at level III), won clean. L1 control -> 0 groans across a full run, won clean. No console errors. Sound bar kept: synthesized, low level, no highs.


## Cycle 76 - the balcony reveal lifts (2026-09-25, ~7:04 AM IST)
Grade: PASS (local verified; deploying).
Audit first: the fail path was frame-verified this cycle and needed no patch - "THE OIL IS LOW" toast + shrunken flame + closing vignette (c76-gutter.png), then "THE LAMP GUTTERED" card over a fully dark stair with "THE STORM TAKES THE STREAK" (c76-failcard.png). The most common outcome in the game reads exactly right.
Finding: the second-landing balcony door - "the tower opens to the storm, moonlit sea, rain off the head" - showed in real playthrough frames as a dark railed opening with only a glint band (c76-balcony-live.png, th 7.56): the vista plane was too dark to read, weaker than its fiction.
Built: the door's vista plane now emits its own texture (energy 0.55) and the moon-spill pool at the threshold rises 0.3 -> 0.42 alpha. Strictly additive - the plane renders ~1.55x its old light.
Verified: check-only clean; export 111,648B; verify3 WON ok. Before/after at the same climb moment: pre-patch the opening is a dim shape; post-patch burst0 (th~7.9, looking back-down) shows the doorway glowing with the moon disc clearly reading in it. Honest caveat: a straight-on still of the door is hard to catch in motion (camera sweeps past in ~2s); the lift is physically guaranteed by the additive emission, and the playthrough frames confirm it.


## Cycle 77 - the storm breathes through the balcony door (2026-09-25, ~7:27 AM IST)
Grade: PASS (audio cycle, trace-verified - no frame, by design).
Finding: the window-swell system (c70) makes rain and surf rise as the keeper passes each open window, but its source list (tower.win_pos) only covers the four windows. The balcony door - an open doorway to the storm, visually lifted in c76 - was sonically silent: you could watch rain off the head in dead quiet.
Built: the balcony door (th 7.6, opening center y 9.1) is now an additional source in the same swell computation - same 5-unit falloff, same squared curve, same +4 dB ceiling on rain (x0.7 on surf). No new sound; the existing storm bed simply breathes at the door the way it already does at the windows.
Verified: check-only clean; export 111,728B; verify3 WON ok (re-run after re-splitting the b64 parts - the first verify3 pass had run against stale c76 parts; caught by part timestamps, re-split, re-verified). Harness (pck served via split-pack loader, balconyhold pin): "window swell +2 dB th=7.3" - matches the math exactly (+1.98 dB at the pin, rising to ~+3.6 dB at the door itself). The gallery window contributes zero at that spot (7.5 units out), so the swell is provably the door. Sound bar kept: synthesized, low level, no highs.


## Cycle 78 - the foghorn has a source (2026-09-25, ~7:59 AM IST)
Grade: PASS (texture-verified; honest note on in-game framing below).
Finding: the foghorn sounds every 40-75s during play, but the two biggest sea views - the gallery window and the balcony door vista, both drawn from tex_vista() - showed moon, sea, stars and no ship. The narrow windows have a blinking ship light (win_lights), but the vistas the player actually studies read as empty sea answering the horn.
Built: a distant ship in tex_vista() - a small warm light (3x2 at (66,176), hull; 1px masthead above) low on the sea near the horizon haze, with a 4-pixel fading warm reflection below. Placed at x=66, clear of the moon (x=150) and its reflection shimmer (x 123-177), so the two lights never merge. Static (the vista is a baked texture); the horn remains the audio cue.
Verified: check-only clean; export 111,984B; b64 parts re-split as a distinct verified step (parts sha256 == pck sha256 == ddad56dd...); verify3 WON ok. Texture-level pixel verification on the actual tex_vista() body extracted from main.gd and run headless: ship pixels (66-68,175-177) carry the warm light, reflection at (66,179) = 0.28 alpha as written, controls unchanged (moon bright, sea at (30,220) and (220,176) dark navy - no stray warm pixels). Honest note: three in-game capture attempts (gallery burst, balcony-pin burst) did not land the window/door plane in frame - the documented gallery framing gap stands - and at ~3 texture pixels the light is below reliable still-frame threshold anyway; the c76 frames already prove this texture renders on the door plane in-game.


## Cycle 79 - win-flow audit (2026-09-25, ~8:29 AM IST)
Grade: PASS (audit-only cycle; no patch - nothing to fix).
Scope: the whole winning sequence on the current build at storm II, phone portrait 480x800, frames captured trace-triggered (relight, ignite, won card settled +2.5s).
- Relight: the glass drum reads as a real lamp room - bronze mullions, stars and rain through the glass, the storm-II violet sky at the edges, a pane mid-flight refitting the lens (c73 work holding up).
- Ignite: the drum blazes warm, lens rings visible through the glass, light spilling across floor and ceiling while the storm stays dark at the edges.
- Win card: "THE LIGHT HOLDS / THE CLIMB TOOK 0:16 - A NEW BEST - STORM III AWAITS" (the 0:16 is the fast=1 debug clock, not a bug) over the lit tower with twin beams sweeping the black water and the lamp glow flaring below. The ship line and the KEEP IT AGAIN button read clean at phone size.
No deploy impact (log entry only); deploy of cycle 78 still held on browser availability (see DEPLOY-PENDING.txt).


## Cycle 80 - title + touch layout audit (2026-09-25, ~8:58 AM IST)
Grade: PASS (audit-only cycle; no patch - nothing to fix).
Scope: real phone viewport (iPhone-class 390x844 @2x, hasTouch), storm II, current build.
- Title (c80-title.png): "KEEP THE LIGHT / STORM II - THE SEA TESTS YOU AGAIN" card over the night sea, tower silhouette with the lamp out at right, rain slants and stars reading clearly. Card text legible at phone size, BEGIN button thumb-reachable. Touch controls (stick, JUMP) visible on the title screen - acceptable: they are needed the instant the climb begins, no change.
- Start of climb (c80-touch.png): "DRAG THE LEFT SIDE TO CLIMB" hint toast up, keeper at the tower door with the lantern lit, contact shadow grounding him on the step (c71 holding up), warm pool spilling across the stair. The keeper fills a large share of the frame at the start - deliberate and reads well. HUD: oil bar labeled, storm-II pips + label, mute/pause chips, stick and JUMP in the corners - none overlap at 390px.
No deploy impact (log entry only); cycle 78 deploy still held (see DEPLOY-PENDING.txt - browser GitHub session signed out, re-approval pending with the user).


## Cycle 81 - storm-V identity audit (2026-09-25, ~9:27 AM IST)
Grade: PASS (audit-only cycle; no patch - queue frozen per parent). One candidate logged for a future cycle.
Scope: storm V on the current build, title + early climb, 480x800. Traces: "storm identity lvl=5 tint=(1.18, 0.7, 0.6) dark=0.7", "storm level L=5 oil=64 gustx=0.6".
- Early climb (c81-play5.png): the storm-V identity lands - warmer/redder tint, tighter lantern pool against the dark, moonlit window glow behind the keeper, "THE VILLAGE IS FAR BELOW" beat on time, pips + STORM V label right, oil 64 (80 - 4x4) correct.
- Title (c81-title5.png): the menace reads - dense rain, near-black sky, the lamp-out tower barely there. CANDIDATE for a future cycle: at storm V the title tower is close to invisible (dark=0.7 vs storm II's readable silhouette in c80-title.png). A small floor on title-scene darkness (e.g. clamp title dark to ~0.82) would keep the drama without losing the tower. Not patched now: deploy queue is frozen (audit-only cycles until the held cycle-78 push lands).


## Cycle 82 - flash + desktop pause/mute audit (2026-09-25, ~9:59 AM IST)
Grade: PASS (audit-only cycle; no patch - nothing to fix).
Scope: lightning flash visuals and the desktop chip variants (c74 covered touch).
- Lightning (c82-flash.png, storm IV, flashhold pin): the flash reads as a real strike, not a whiteout - wall stones lift violet-white around the window flash materials, the bay frame silhouettes, the lantern pool holds warm against it. The double-strobe and decay were trace-verified back in cycle ~9; the held frame now confirms the composition.
- Mute chip (desktop): click fires SOUND OFF toast - works (c82-pause.png; the click also proved chip hit-boxes are separate - 452px hit mute, 473px hit pause, no overlap).
- Pause chip (desktop, c82-pause2.png): trace "paused panes=1 t=0:04 oil=80"; card reads "PAUSED / 1/5 PANES - 0:04 - OIL 80" with the keyboard controls text (A/D, arrows or left stick; SPACE or JUMP; ESC - back to the stair) - the desktop variant of the c74 card, correct per platform, RESUME button clean.
No deploy impact (log entry only); cycle 78 deploy still held (browser GitHub session signed out; Naksh's sign-in approval pending - no solo login attempts per parent's 9:55 instruction).


## Cycle 83 - the stolen stick (Naksh's can't-drag bug) (2026-09-25, ~10:46 AM IST)
Grade: PASS (local verified; deploy held with the rest of the queue).
Report (Naksh, live on his phone): "glitches and bugs... the fixed and animating/moving but static player and the moving background... i can't drag around."
Diagnosis: the virtual stick only engaged if NO other touch held it (`stick_id == -1` required). A stale or unnoticed resting touch - palm, second finger, or a press whose release the browser dropped - locked the slot. His intentional drag then fell into the peek branch (any non-stick drag rotated the camera, contradicting the stated controls "left climbs, right peeks"). Result, exactly his words: the keeper idles (the 4.5s idle look-up anim plays - "animating but static"), and the background rotates on drag ("moving background", "can't drag around"). Reproduced in touch-emulated CDP harness: resting left finger + drag with a second finger -> 0 climb traces, keeper static.
Fix (three small changes, one input-robustness pass):
1. The newest left-half touch always takes the stick (steals it from any stale/resting touch).
2. Peek now belongs to right-half touches only (tracked peek_id), so a left-half drag can never rotate the view - the halves match the stated controls.
3. stick_id/stick_x/peek_id reset at every run begin - no stale touch survives a restart.
Verified: check-only clean; export; parts sha == pck sha == a372b570...; verify3 WON ok. Touch-emulated CDP harness on the fixed build: TEST A (resting finger + drag with second) -> 3 climb swell traces (was 0), 0 peek; TEST B (single finger) -> climbs as before; TEST C (right-half drag) -> peek trace fires (peek alive). No left-half drag peeks anymore.
Also noted, not fixed this cycle: his screenshot shows the keeper's torso occluded by the stair slab at the start - reads as clipping from the follow camera; candidate for a future camera/angle cycle.


## Cycle 84 - the occluded keeper audit (second half of Naksh's report) (2026-09-25, ~11:05 AM IST)
Grade: PASS (audit-only cycle; no patch - no separate defect found). One candidate logged for a future camera cycle.
Report: Naksh's screenshot shows the stair slab crossing the keeper's torso at the start - reads as clipping.
Method: 10 real frames on the queued c83-fixed build, phone viewport 390x844 @2x, storm II: 6 start-of-climb views (c84-start0-5), 3 in the first 2.6s after a manual BEGIN (c84-trans0-2), and a full right-half peek swing (c84-peekA/B).
Findings:
- Every normal-play frame reads clean: the keeper is fully visible at the door and on the first steps; the rail crosses at shin level at most, a normal depth cue.
- The occluded composition in his shot is a real but transient perspective: the camera trails on the downhill side while the first flight rises across the sightline, so a step edge can cross the keeper's torso for a moment. His session sat in that state because of the c83 bug - his drags fell into the camera-peek branch and swung the view into odd angles while the keeper stayed put. With the stick fix, drags climb and the camera trails normally, so the composition resolves as soon as he moves.
- Not patched: a camera-side change (near-keeper occlusion fade, look-target raise) alters game feel everywhere and deserves its own before/after cycle, not a rush into the frozen midnight queue. Candidate logged: if post-fix play still shows the slab read, options are fading stair geometry that sits between camera and keeper, or a small look-target height bump low on the first flight.
No deploy impact (log entry only); queue unchanged (c78 + audits + c83, expected pck sha a372b570...), deploy held for the post-midnight browser budget reset.


## Cycle 85 - desktop input regression audit (c83 fallout check) (2026-09-25, ~12:10 PM IST)
Grade: PARTIAL - keyboard climb and pause PASS; one real bug found (desktop drag-peek dead on web), fix proposed and held (audit-only per parent).
Scope: the queued c83-fixed build on a desktop viewport (1280x800, mouse + keyboard), storm II, fast=1. The c83 patch touched only the touch handlers; this audit checked the desktop paths beside it.
- PASS keyboard climb: D and ArrowRight both climb - window-swell traces 0 before keys, 1 after 4s of D, 4 after 3s more of ArrowRight. c85-climb.png: the keeper mid-flight with the "PANE RECOVERED - +5S OIL" toast - he reached and took a pane by keyboard alone.
- PASS pause: ESC pauses ("paused panes=1") and resumes clean. c85-pause.png: the desktop PAUSED card with the correct keyboard-controls text.
- FAIL desktop drag-peek: the pause card advertises "Drag - peek around the curve", but a left-button mouse drag does nothing on the web build. Evidence: a CDP-driven drag delivered 26 mousemove + 26 pointermove events on the canvas with buttons=1 (confirmed by a DOM-level listener), and the engine stayed silent - no peek trace, and the keeper's 4.5s idle look-up fired DURING the drag. Synthesized mousemove/pointermove with buttons=1 are ignored identically. Root cause: the handler gates on InputEventMouseMotion.button_mask, which the Godot 4.3 web runtime reports as 0 in motion events (engine-side gap); InputEventMouseButton works fine (clicks land). This predates c83 - the path is untouched since long before today, so desktop peek has likely never worked on the web build.
Fix (held for the parent's go, ~4 lines): track left-button state from InputEventMouseButton (which works) and peek on motion while it is held - mask-independent, and identical behavior wherever the mask already works. Not patched now per the audit-only directive; candidate for the first post-deploy cycle unless the parent wants it in the midnight queue.
No deploy impact (log entry only); queue unchanged (c78 + audits + c83, expected pck sha a372b570...), deploy held for the post-midnight browser budget reset.


## Cycle 86 - eye of the storm + high-altitude storm audit (2026-09-25, ~1:00 PM IST)
Grade: PASS (audit-only cycle; no patch). One small beat-stomp candidate logged.
Scope: full storm-IV climb on the queued c83 build, phone portrait 390x844 @2x, auto=1&fast=1, trace-triggered frames.
- Beats: all three fire on schedule (th 6 "THE VILLAGE IS FAR BELOW", th 12 "THE STORM IS THICK HERE", th 17 "THE LIGHT IS NEAR").
- The eye: "[KTL] eye th=14.2 h=0.47" - the Gaussian dip works, and it is audible in the wind numbers: db goes -12.2 at y=10.5 to -12.5 at y=15.1, i.e. the wind gets QUIETER while climbing through the eye even though raw altitude should push it louder. The stillness reads in the mix exactly as designed.
- Gusts: hit from both directions at h~0.65 near the top ("gust hits dir=-1/1 v=0.22"). Lightning cadence alive (2 strikes logged). No page errors.
- Frames: c86-thick.png (beat 2, keeper in the thick band, OIL DROP toast) and c86-eye.png (the landing by the eye, pane wisps drifting, lamp-room floor overhead) both read clean - keeper fully visible, no occlusion recurrence.
CANDIDATE (not patched, audit-only directive): the pane slots [2.5, 5, 8.5, 11.5, 14.5, 17.5] put a pane exactly at the eye (th 14.5), and the toast slot is single - so "PANE RECOVERED - +5S OIL" stomps "THE AIR GOES STILL" within a fraction of a second every run (directly visible in c86-eye.png: 1.5s after the eye trace the pane toast owns the slot). The designed stillness beat is effectively masked. Options for a future cycle: nudge the 14.5 pane slot off the eye (e.g. 15.2, spacing stays sane), or move the eye trigger earlier (th ~13.6, dip still ~87% of max). Small either way; parent decides alongside the c85 desktop-peek fix.
No deploy impact (log entry only); queue unchanged (c78 + audits + c83, expected pck sha a372b570...), deploy held for the post-midnight browser budget reset.


## Cycle 87 - storm I first-run audit (2026-09-25, ~2:05 PM IST)
Grade: PASS (audit-only cycle; no patch - nothing to fix).
Scope: the true first-run experience - fresh profile, no debug storm param, auto climb at fast=1, phone portrait 390x844 @2x, full run to the win. This is the level every new player (including Naksh on his first visit) actually starts at, and it had never been audited end to end.
- Identity: "storm identity lvl=1 tint=(1,1,1,1) dark=1" - neutral tint, no extra darkness; "storm audio lvl=1 windp=1 rainv=-13 surfv=-20" - the quiet bed. "storm level L=1 oil=80 gustx=1".
- Gentleness checks out against the storm-IV numbers from c86: 1 gust hit + 2 warnings (vs constant pressure at IV), 4 lightning strikes across the run, eye h=0.21 (vs 0.47 at IV) - the tower at storm I is genuinely calmer air. Oil never threatened (0 low-oil warnings on the auto line).
- Beats 1-3 and the eye all fire; ignite lands; win card reads "THE CLIMB TOOK 0:16 - A NEW BEST - STORM II AWAITS" (0:16 is the fast=1 debug clock) with is_best=true and the ship line. Progression to storm II correct. No page errors.
- Frames: c87-mid.png (beat 1, "THE VILLAGE IS FAR BELOW", keeper climbing past a moonlit window - clean), c87-ignite.png (the drum blazing, lens rings through the glass, light flooding the lamp-room ceiling - the payoff reads), c87-won.png (THE LIGHT HOLDS card over the lit tower, beams over black water, lamp glow pooling below). Honest note: the intended title frame caught the auto-begin instead (auto=1 starts the run by design), so no storm-I title still this run - the title card itself was audited in c80 and storm-I identity is covered by the traces above. No "relight" trace exists in the build (the phase is covered visually in c79), so the harness's relight flag stayed false by construction.
No deploy impact (log entry only); queue unchanged (c78 + audits + c83, expected pck sha a372b570...), deploy held for the post-midnight browser budget reset. Post-deploy bundle per parent: c85 desktop-peek fix + pane slot 14.5 -> ~15.2 (eye trigger stays).


## Cycle 88 - fail-path re-audit on the queued build (2026-09-25, ~3:00 PM IST)
Grade: PASS (audit-only cycle; no patch - nothing to fix).
Scope: the fail flow on the queued c83 build, re-verified because the input/UI stack changed around it since c76 (chip layer in c74, stick/peek rework in c83). Manual BEGIN (no auto), storm II, startoil=1, fast=1, phone portrait 390x844 @2x - the keeper stands at the door and the lamp burns down.
- Sequence fires in order: begin -> "[KTL] lowoil" -> fail card + "fail panes=0". No page errors.
- c88-lowoil.png: "THE OIL IS LOW" toast with the oil bar flipped to rust red (the warning color still lands), keeper at the door, lantern lit against the darkening stair.
- c88-fail.png: "THE LAMP GUTTERED" card over the fully dark stair - "THE OIL RAN OUT ON THE STAIR - 0 OF 5 PANES LIT - THE STORM TAKES THE STREAK", flavor line "The tower goes dark, and the rain keeps what it took. Another can of oil, another climb.", TRY AGAIN clean, the keeper a bare silhouette. The most common outcome in the game still reads exactly right on the build Naksh will get.
No deploy impact (log entry only); queue unchanged (c78 + audits + c83, expected pck sha a372b570...), deploy held for the post-midnight browser budget reset.


## Cycle 89 - the stair gap + oil drops audit (2026-09-25, ~4:20 PM IST)
Grade: PASS (audit-only cycle; no patch). The missing-stair jump - the scariest moment in the climb - works end to end.
Scope: the gap at th 10.0-10.3 (never verified end-to-end before) and the oil-drop pickups (seen in frames, never traced), phone portrait 390x844 @2x, storm II, manual two-thumb play via CDP touch.
- Nudge: at th>9.55 the game toasts "A STAIR IS MISSING - JUMP" and pulses the JUMP button (c89-gap.png - toast up, keeper at the edge). Trace: "gap nudge pulses jump button".
- The jump: a two-thumb tap (left thumb holding the climb, right thumb on JUMP) fires the jump and carries the keeper over the gap: "gap cleared th=10.4" + "land squash th=10.4" - landing past GAP[1]=10.3 earns the made-it beat (soft chime + lantern bloom, per the code path that prints the clear trace).
- Oil drops: collected mid-climb on the same runs - "drop +8 oil=84.8 th=4.8" (sip sfx, +8s oil, capped at 95). Panes 1-3 collected on the climb with correct chime traces.
- Verification honesty note: the end-to-end clear was captured on an instrumented copy of the project (identical main.gd plus three temporary trace prints, discarded after the run), because the CDP touch harness needed two calibration fixes that have nothing to do with the game: (1) headless Chrome scales touch coords ~2.46x into Godot's viewport space, so the JUMP-button tap must be computed in engine coordinates, not CSS pixels; (2) CDP touchEnd semantics released the stick thumb on the first attempts, killing forward motion mid-jump. The un-instrumented queued build resisted the same harness (a double-tap race in my own listener on the two "gap nudge" trace lines); the game logic under test is byte-identical either way, and on a real phone viewport and hit-test share one coordinate space, so neither artifact can occur for Naksh. No player-facing defect found.
No deploy impact (log entry only); queue unchanged (c78 + audits + c83, expected pck sha a372b570...), deploy held for the post-midnight browser budget reset.


## Cycle 90 - restart flow audit (TRY AGAIN after a fail) (2026-09-25, ~5:00 PM IST)
Grade: PASS (audit-only cycle; no patch - nothing to fix).
Scope: fail -> TRY AGAIN -> play on, on the queued c83 build. This is a direct regression check of the c83 reset path (stick_id/peek_id reset at run begin) and of reset_run itself. Manual BEGIN, storm II, startoil=1, fast=1, phone portrait.
- First run burns down and fails correctly ("fail card: THE OIL RAN OUT ON THE STAIR - 0 OF 5 PANES LIT - THE STORM TAKES THE STREAK").
- TRY AGAIN tap starts a second run (begins=2). The restart is clean: the "storm level" trace shows the same starting oil as run one - the run-one burn to zero did NOT leak into run two. A stick drag in the restarted run climbs immediately: "pane 1 chime=chime1 th=1.6" + 2 window swells. The c83 stick reset does not eat the first post-restart press.
- c90-restart.png: the keeper back at the door at th=0, lantern lit, controls up, oil bar reset to the run's starting value (the "THE OIL IS LOW" toast is the startoil=1 debug param applying to every run in the session, not a state leak - both runs started at the same low oil by construction). No page errors.
No deploy impact (log entry only); queue unchanged (c78 + audits + c83, expected pck sha a372b570...), deploy held for the post-midnight browser budget reset.


## Cycle 91 - persistence + storage-guard audit (2026-09-25, ~6:05 PM IST)
Grade: PARTIAL - one real bug found (trace-verified, numbers below), fix proposed and held for the parent's call. Audit-only cycle; no patch.
Scope: localStorage persistence - best time, storm progression, and the debug-param guard. The project's own invariant is "debug runs never touch stored progress"; the setters for ktl_storm, ktl_held and ktl_calm all check STORM_OVERRIDE. Verified end to end with a forced debug win (storm=3&auto=1&fast=1), then a clean reload.
- GUARD WORKS where it exists: after the debug win, ktl_storm / ktl_held / ktl_calm are all null - the forced storm-III win did not advance the stored streak. Clean reload correctly starts at storm I.
- BUG: ktl_best has NO guard (main.gd line ~1965). The debug win wrote ktl_best="16.06668" - a fast=1-compressed 16 seconds no honest run can match - and the clean reload greeted me with "title remembers best=0:16". Any ?storm= or ?fast= link that ends in a win permanently clobbers that profile's best time. (fast=1 alone, no storm param, would do the same - the write checks neither.)
- Impact: latent, not user-facing today - Naksh plays the plain URL, so his best is safe. But the invariant is broken and one shared debug link would wreck a profile's best.
Fix (one line, held): make is_best itself false under debug - `var is_best = OS.has_feature("web") and STORM_OVERRIDE == 0 and not FAST and (prev <= 0.0 or ST.elapsed < prev)` - so the write, the "new best" print AND the win card's NEW BEST claim all stay consistent. Propose bundling with the post-midnight c85/pane-slot cycle.
No frame this cycle - the finding is storage state + traces, nothing visual. No deploy impact (log entry only); queue unchanged (c78 + audits + c83, expected pck sha a372b570...), deploy held for the post-midnight browser budget reset.


## Cycle 92 - the storm-V capstone (prestige loop) audit (2026-09-25, ~7:10 PM IST)
Grade: PASS (audit-only cycle; no patch - nothing to fix).
Scope: the full progression to the capstone, never verified before. Five honest consecutive wins in one session (no debug override - the capstone block only runs when STORM_OVERRIDE==0, so it had to be earned), auto climb at fast=1, desktop viewport.
- Progression: "storm level next=2 -> 3 -> 4 -> 5" across the four wins, each win card carrying the right "STORM N AWAITS" line.
- The capstone: the fifth win (storm V) fires "storm held total=1 calm earned" and "storm level next=1" - the sea quiets back to I. Win card reads "THE CLIMB TOOK 0:16 - A NEW BEST - THE HIGHEST STORM HELD - THE SEA QUIETS" (0:16 is the fast=1 debug clock; all five runs land at ~16s, which is also why one mid card reads "BEST 0:16" - an artifact of identical debug times, not a display bug).
- Persistence: localStorage after the capstone - ktl_storm="1" (reset), ktl_held="1", ktl_calm="1". The whole tally path writes legitimately, complementing c91's guard audit.
- Best-time logic: is_best true on the first win, false on slower reruns, true again when the fifth edges it (16.05 < 16.1) - consistent.
- c92-capstone.png: THE LIGHT HOLDS card over the lit tower, beams sweeping, five pips up top, capstone sub-line in place.
No deploy impact (log entry only); queue unchanged (c78 + audits + c83, expected pck sha a372b570...). Deploy gate: parent's fleet-wide fresh go (not midnight alone). Post-deploy bundle approved: c85 desktop-peek fix + pane slot 14.5->15.2 + ktl_best guard.


## Cycle 93 - fleet web-surface standards (favicon / title+meta / 404 / error states) (2026-09-25, ~7:20 PM IST)
Grade: PASS (all four standards verified with real frames on the exported build; queue-only, deploy still held).
Scope: the parent's fleet checklist: favicon, real page title + meta description, decent 404, no placeholder text, honest empty/success/error states - no raw stack traces ever.
- apply_loader.py rewritten to own ALL index.html customization idempotently (split-pack loader + theme style + meta description/theme-color + failure mapping). One script now reproduces the whole shell; no more drift between copies.
- Title/meta: "KEEP THE LIGHT" title (already in place), meta description ("Climb the lighthouse. Keep the flame alive through the storm.") and theme-color #0a0f18 added. Favicon: the tower-mark png already ships as favicon (verified in the shell).
- 404: NEW build/404.html - branded "LOST IN THE STORM" cream card ("This page is not on the stair.") with a BACK TO THE TOWER link to /keep-the-light/. GitHub Pages serves it for any unmatched path under the site.
- Error state: displayFailureNotice now maps engine/loader errors to plain language ("A piece of the tower failed to arrive. Check your connection and reload - the climb is worth it."); raw detail stays console-only. Splash + progress hidden in the failure path so the message stands alone.
- FOUND + FIXED in-cycle: Godot's stock #status-notice style (maroon box, engine default) was still showing behind the friendly text - off-brand engine chrome, exactly what the fleet standard targets. Restyled to the cream card in the loader's style block (both apply_loader.py and build/index.html, byte-identical edits).
- Verification (local server, COOP/COEP headers, phone portrait 390x844): normal boot ready:true on the modified shell; c93-error.png = the friendly cream card with part 3 of the pck deliberately missing (HTTP 404 from the server); c93-404.png = the centered 404 card. Two earlier passes caught the maroon box and a top-pinned 404 before this final pass.
- parts integrity re-verified after the shell edits: recombined b64 parts sha256 == pck sha256 == a372b570553bd271d625d6cbc6e30dd3821d6b78688c21d06d796b7bceac7a41 (shell edits don't touch the pck, but checked anyway).
Deploy impact: 404.html is a NEW 8th deploy file; index.html changes ride the queue. Queue now: c78 + audits 79-92 + c83 + c93 shell, expected pck sha a372b570... . Deploy gate unchanged: parent's fleet-wide fresh go.


## Cycle 94 - mobile touch drag-peek audit (2026-09-25, ~8:05 PM IST)
Grade: PASS (audit-only cycle; no patch - nothing to fix).
Scope: the touch peek path (right-half drag around the curve), the touch sibling of the c85 desktop bug. Desktop peek is broken by InputEventMouseMotion.button_mask==0 on Godot 4.3 web (fix staged in the post-deploy bundle); the touch path uses InputEventScreenDrag with index tracking instead, so it was expected healthy - now verified on the queued build, phone portrait 390x844, storm I, manual BEGIN.
- Single-finger right-half drag: "peek=0.51" trace fires; release eases the camera back (c94-peek.png vs c94-restore.png - the swing is subtle at the door because there is little parallax there, but the doorway/rail shift is visible).
- Multitouch: left-half stick + right-half peek together - "peek=0.61" while the stick kept climbing: c94-multi.png shows the keeper several stairs up with the "PANE RECOVERED - +5S OIL" toast from a pane collected during the two-finger phase. Neither finger steals the other (the c83 newest-touch rule only applies within the left half).
- No page errors. localStorage untouched (storm=1 debug param; guards verified in c91).
Conclusion: Naksh's phone peek works today; only DESKTOP drag-peek needs the staged c85 fix.
No deploy impact (log entry only); queue unchanged (c78 + audits + c83 + c93 shell, expected pck sha a372b570...). Deploy gate: parent's fleet-wide fresh go.


## Cycle 95 - FINAL CYCLE: bundle + security pass + full sweep (2026-09-25, ~8:30 PM IST)
Grade: PASS. User directive: finish this version - secure, safe, no bugs, functional - as the final cycle for now. Everything below verified on the FINAL exported pck 71ce3e85b9fc43679edd630ad62622a7f9e5673711d042bf7d3d17c037344a8a (deterministic export; the exact bytes every test ran against). Staged locally; deploy still waits for the fleet-wide go.
BUNDLED (the approved post-deploy bundle, applied now so the final version carries it):
1. ktl_best guard (real bug, c91): is_best now requires STORM_OVERRIDE==0 and not FAST. Verified: forced debug win (storm=3, auto, fast) -> "won elapsed=16.25 is_best=false", localStorage ktl_best AND ktl_storm both null after the win, and the win card (c95-guard.png) shows no "A NEW BEST" claim. Real profiles can no longer be poisoned by a shared debug link.
2. Pane slot off the eye (design directive): the 4th pane slot base moves 15.6 -> 16.3. TRANSPARENCY: the parent's instruction said "14.5 -> ~15.2", but 14.5 was never the pane slot - my c86 note quoted the SCONCE list; the real pickup slot was 15.6 with -0.45 jitter (could land at 15.15, still inside the eye's suppression tail). Applying "15.2" literally would have made it worse (jitter min 14.75 = inside the eye trigger). The intent - pickup lands clearly after the designed stillness - is what shipped: verified pane 4 chime at th=16.6 vs eye at th=14.2 (C harness, storm IV, all 5 panes collected).
3. Desktop drag-peek "fix" (c85) - HONEST REVERSAL: there was no bug. Instrumented probing showed button_mask=1 arrives correctly in Chrome; the live cycle-77 build and the patched build produce IDENTICAL peek traces (peek=-0.72, peek=0.59). c85's zero-trace was a swiftshader artifact: headless frame times make the per-frame peek decay (~45%/frame at swiftshader dt) outrun CDP's discrete mouse-move accumulation; on real 60fps hardware a normal drag reaches the threshold easily. The mask-independent button tracking (mouse_lb) stays in as zero-cost hardening for browsers that might report mask 0 - behavior identical in Chrome, verified.
SECURITY PASS (static, whole surface): no network calls anywhere (no fetch/XHR/WebSocket in game or shell beyond the loader's same-origin part fetch), zero third-party URLs, no eval of user-controlled strings (JavaScriptBridge.eval used only with clamped numbers / JSON.stringify'd vibrate pattern / fixed localStorage keys), URL params parsed with fixed offsets + numeric clamps, localStorage writes are clamped ints/flags, no credentials in the repo (scan hit was the word "token" in CYCLES.md prose). Godot's stock maroon notice box restyled in c93.
FULL SWEEP on the final pck: verify3 WON ok (5 chimes, win). Boot clean on the c93 shell. Win path (B above), fail path (D: "THE LAMP GUTTERED - 0 OF 5 PANES LIT", TRY AGAIN, c95-fail.png), pane traces all 5 with correct slots, no page errors in any harness page, localStorage clean after debug runs.
Deploy queue (go-time push list, 9 files): main.gd, CYCLES.md, index.html, index.pck.b64.0-3, 404.html, FEATURE-MAP.md. Expected pck sha 71ce3e85... (supersedes a372b570...). KTL goes quiet after this cycle per the user's directive.


## STANDING GATE (owner via parent, 2026-09-26 5:26 PM IST)
Nothing public - Pages deploys, public File publishes, store uploads, releases - without the owner's explicit yes relayed through the parent. Midnight browser windows are for staging, commits, push prep and PRIVATE artifacts only. The cycle-95 deploy (live 1:59 AM) predates this refinement and was under the 8:54 PM fleet go. All future KTL pushes hold at the gate.

## SAVED STATE (owner directive, 2026-09-26 ~5:25 PM IST)
Local repo /home/sandbox/ktl-repo HEAD feb4d65. Live tip fe00436 == local, pck sha256 71ce3e85b9fc43679edd630ad62622a7f9e5673711d042bf7d3d17c037344a8a (byte-verified at deploy). Project /home/sandbox/ktl-godot (main.gd, this file, FEATURE-MAP.md, apply_loader.py, verify3.js, build/). Frames /home/sandbox/ktl-shots/. Nothing pending: no uncommitted work, no staged push.


## Cycle 96 - CHAPTERS step 1: the data-drive refactor (2026-09-26, ~6:30 PM IST)
Grade: PASS (local only; standing gate - nothing public).
Scope: introduce the content axis. TOWERS table in main.gd (name/tint/moon/gust/spark/groan/seed/motif_root per tower); apply_storm_identity is the single substitution point (storm tint and moon now compose with the active tower's identity). CHAPTER reads ktl_chapter from localStorage (default 0; the guarded write lands with the voyage in c97). Tower 1 = THE FIRST LIGHT with identity multipliers, i.e. today's exact night. Towers 2 (THE BASALT WATCH) and 3 (THE EMBER SHOAL) carry their palettes in the table, inert until unlocked.
- Regression on the exported build (pck 26b17174): storm-I identity trace "tint=(1, 1, 1, 1) dark=1 tower=THE FIRST LIGHT" - byte-identical tint/dark to the live build's trace; storm-IV "tint=(1.1, 0.83, 0.85, 1) dark=0.78" matches STORM_TINTS[3] exactly. Pane slots unchanged (th 1.3/7.4/9.3/16.3/18.1, within jitter of live's), eye at th=14.3. verify3 WON ok. Zero page errors. Parts re-split line-broken (4 x ~38KB).
- No frame this cycle: the visual output is identical BY CONSTRUCTION (every palette application multiplies by Color(1,1,1)); the trace equality above is the stronger evidence. Honest note per convention.
- Doc spine (STATE.md, MISTAKES.md, PLAN.md, FEATURE-MAP.md full version) committed alongside, per the fleet directive.


## Cycle 97 - THE VOYAGE: coastal map + chapter unlock + tower 2 boots (local, gated)
Built: the storm-V capstone becomes a voyage. Win card after a capstone hold reads SEE THE COAST (dispatcher _on_end_pressed); THE COAST map screen (custom MapDraw Control: night coast silhouette, sea glints, moon, three tower lights with per-tower tint colors, beams on lit towers, tap-to-select with lock feedback toast) with SAIL/BACK; chapter_set() writes ktl_chapter guarded exactly like the streak keys (STORM_OVERRIDE>0 or FAST -> "chapter write guarded (debug)" trace, no write; store only moves forward; sail-back is session-only via sail_pending). Title screen names the tower and offers THE COAST when chapter>0. Identity multipliers wired: spark divides lightning interval, gust scales gust force + frequency, groan scales groan pitch (tower 1 all 1.0 = identity). chapter=N debug param for tower boot tests. Export 118,896B; parts re-split (-a 1, 4 non-empty) reassembly sha == pck sha 2851f8d1c92674059c3584590131964785cd1de5251f2ef4c326511572fb443d; check-only clean.
Verified: verify3 WON ok. T1 regression: storm-I identity byte-identical to live ("tint=(1, 1, 1, 1) dark=1 tower=THE FIRST LIGHT"). T2: chapter=1 boots THE BASALT WATCH, tint composes ("tint=(0.82, 0.9, 1.1, 1) dark=1 tower=THE BASALT WATCH"), clean win, "tower boot name=THE BASALT WATCH chapter=1". T3 real capstone (ktl_storm=5 via JS, no debug, no fast): "storm held total=1 calm earned", win card "... THE SEA QUIETS - THE COAST WAITS", SEE THE COAST click -> "coast shown chapter=0 unlocked=1", localStorage held=1/storm reset/chapter null pre-sail. Zero page errors in all runs. Frames: c97-wincard.png (SEE THE COAST card), c97-coast-t3b.png (map: warm lit First Light, ring-selected Basalt Watch, dim locked Ember Shoal, SAIL/BACK), c97-t2-won.png (KEEP IT AGAIN at non-capstone win - dispatcher correct). Grade: PASS pending sail-click e2e (button coords miss in first harness pass - corrected and rerunning; result appended below).


## Cycle 98 - seeded layout + guard coherence + control-ktl.mjs (local, gated)
Built (logic-first, owner 7:46 PM directive; RULE 5/6 applied): (1) control-ktl.mjs - the repo's control CLI (doctor/snapshot/screenshot/wait-settle/interact; JSON out; --dry-run on the build; descriptive errors); all verification below ran through it. (2) Seeded layout: layout is now a pure function of TOWERS.seed (RandomNumberGenerator, seed*1000003 + salt; c99 XORs the date). Tower 1 keeps the exact base points and jitter RANGES (positions were drawn from the time-seeded global RNG before - the distribution is unchanged, only now deterministic); towers 2/3 draw larger base offsets for distinct climbs, same gap guard. Layout regenerates on reset_run by repositioning existing nodes (no rebuild). CHAPTER read early in _ready so the first identity/layout applied is the stored tower's. (3) Guard coherence: capstone held/calm write gains the FAST guard (ktl_best/ktl_chapter already had it); a guarded sail now stays ashore (sail_pending only set when the write can happen; chapter=N remains the debug boot path). pck c17a98969f83f1f9ac71233d2aafcee059690ce849bd495d932c817684e8eaf7, parts 4 non-empty, reassembly match, check-only clean.
Verified (all via control-ktl.mjs): doctor ok (7/7 checks); snapshot ok (sha verified); verify3 WON ok on the new build. Determinism: two separate sessions at tower 1 -> byte-identical layout trace "panes=[2.09, 7.35, 9.18, 16.12, 18.11] drops=[4.89, 12, 17.17]". Tower-1 fidelity: every pane within today's jitter envelope (bases 1.7/7.6/9.5/16.3/18.3, ranges unchanged). Distinct+stable: tower 2 panes=[1.91, 7.94, 10.41, 16.48, 17.7] (pane 3 sits past the gap - guard worked), tower 3 panes=[2.12, 6.54, 9.78, 16.41, 18.92], each repeated identically in-session and across sessions. Guard test (interact, FAST, ktl_storm=5): win writes NOTHING - ktl_held null, ktl_calm null, streak stays V ("storm level next= 5"). Sail-guard code path read back (returns before sail_pending; chapter_set's own guard e2e-verified in c97 T4) - the in-game click path for it is a debug-only edge, noted not click-tested. Frame: c98-t2-layout.png (tower-2 full climb on the new layout - "THE LENS IS WHOLE", 5 pips, cold Basalt palette) eyeballed PASS. Zero page errors in all runs. Grade: PASS.


## Cycle 99 - TODAY'S CLIMB: daily-seed mode + guarded daily best (local, gated)
Built (logic-first): a second mode on the title card, TODAY'S CLIMB. daily_mode + DAY_OVERRIDE vars; day=YYYYMMDD debug param; today_int(); layout_seed() XORs yyyymmdd into the tower seed when daily_mode (the c98 seed architecture made this a one-line change by design). Daily best keyed "yyyymmdd:seconds" in ktl_daily_best via daily_best()/daily_best_set(), guarded on STORM_OVERRIDE/FAST exactly like the other keys. win_run() daily branch: TODAY'S-climb win-card text ("TODAY'S CLIMB TOOK 0:16 - A NEW DAILY BEST - STORM II AWAITS"), does not touch ktl_best/ktl_streak. Title chip shows TODAY'S CLIMB with the day's best (or none); _on_begin_title clears daily, _on_begin_daily sets it; daily toast on begin. pck sha 51ca6358084c, parts 4 non-empty (split -n l/4 -d -a 1), reassembly sha == pck sha, check-only clean.
Verified (all via control-ktl.mjs, KTL_PORT=8961): verify3 WON ok. Canonical layout unchanged when daily=0 (byte-identical to c98 panes [2.09, 7.35, 9.18, 16.12, 18.11]). Title card intact with both buttons - frame c99-title3.png (TODAY'S CLIMB chip at ~(240,469)) eyeballed PASS; fixed the CLI's falsy-default auto-play trap first (MISTAKES #12: default params 'auto=1&fast=1' silently raced the title away and faked a "missing title" regression; bisected c99->c98->c96 before spotting it, default now ''). Determinism: two fresh sessions on day=20260926 -> identical daily layout trace "layout seed=20605565 daily=20260926 panes=[1.96, 7.42, 9.51, 16.04, 18.34] drops=[4.03, 12.53, 17.01]". Different day: day=20260927 -> seed=20605564, panes=[1.34, 7.31, 9.75, 15.85, 18.11] (different, zero errors). Real daily-win e2e (auto=1, no FAST, raced the click into the 0.4s auto-begin window and WON): "daily begin day=20260926" -> daily layout -> "daily best set=0:16 day=20260926" -> "new daily best 0:16" -> win card "TODAY'S CLIMB TOOK 0:16 - A NEW DAILY BEST - STORM II AWAITS" -> won elapsed=16.1 is_best=true; localStorage ktl_daily_best="20260926:16.118..." written and ktl_best stays null (no cross-pollution). Zero page errors in all runs. Grade: PASS.


## Cycle 100 - the keeper's motif: a four-note tune that assembles over the night (local, gated)
Built (logic-first; PLAN.md restatement first per RULE 6): the keeper has a voice. motif_build() lazily synthesizes a 4-note music-box phrase in the active tower's root (TOWERS[].motif_root 69/64/67, inert since c96 - now wired); timbre is sine + 2.0/3.98/7.9 partials with a 4ms attack and long ring (synthesized only, no harsh highs - top partial ~5.5kHz at 0.03 amp). Steps [0,3,7,10] minor-pentatonic: at tower 1 the phrase lands exactly on the pane-chime ladder's own tones (440/523.25/659.25/783.99) - the keeper hums the ladder's song. The tune ASSEMBLES instead of playing whole: begin hums note 1 alone; every pane lit answers with notes 1-2 (the music-box cell, repeating like a real box); a win extends to 1-3; the fourth note exists ONLY at the capstone - the tune completes when the voyage does. Notes spaced 0.42s via tweens, pooled through sfx(). Level: MOTIF_VOL=-14 dB, under the pane chime (-6 dB) - music, not feedback; inspection showed toast() has no sfx, so the pane chime is the feedback ceiling (documented in PLAN.md). pck sha 29fb228b51c3, parts 4 non-empty (41349/41349/41349/41281), reassembly match, check-only clean.
Verified (all via control-ktl.mjs): verify3 WON ok. Normal-win e2e (auto=1): trace sequence exactly "notes=1" (begin), 5 x "notes=2" (pane lits), "notes=3" (win), all "root=69 freq0=440 vol=-14". Capstone e2e (ktl_storm=5 pre-seeded, auto, NO fast - the real write path): same build-up then "notes=4" at the held storm - the last note fired nowhere else in either run. Tower roots: chapter=1 boot -> "root=64 freq0=329.63" (E4, THE BASALT WATCH); chapter=2 boot -> "root=67 freq0=392" (G4, THE EMBER SHOAL). Zero page errors in all four runs. Level asserted numerically in every trace (-14 <= the -6 pane-chime ceiling). Grade: PASS.
No frame this cycle: audio-only, nothing visual changed - trace-verified per the honest no-frame convention. Process slip logged as MISTAKES #13 (--async is a tools-CLI flag, not a node flag; node harness runs detach via setsid + log + poll).


## Cycle 101 - THE BASALT WATCH setpiece: static charge (local, gated)
Built (logic-first; PLAN.md restatement first per RULE 6): Basalt's lightning is now a hazard with counterplay, not just weather - the first per-tower setpiece beyond identity multipliers. A near strike (dist < 0.35, ~1 in 3) at a charge-bearing tower charges the shell for 2.5s with an audible crackle (sputter at -17 dB, pitched 0.5). Moving through charged air accumulates static (dir != 0, the same movement signal as footsteps); 0.5s of movement snaps it: -2 oil and a 0.35 backward shove. Freezing through the window grounds it out - the gust's warn-then-brace grammar with a new trigger. Data-driven: TOWERS gains a charge field (FIRST LIGHT 0.0 = identity untouched, BASALT 1.0, EMBER 0.0 until its own setpiece). State charge_t/charge_move/charge_jolted, all reset in reset_run; the hook sits inside the existing strike roll (read back after patching). pck cff99b94cfbd, parts 4 non-empty, reassembly match, check-only clean.
Verified (all via control-ktl.mjs): verify3 WON ok. Tower-1 inert: full auto win with ZERO static traces - the identity is untouched. Basalt playable: full chapter=1 auto win, zero page errors. Mechanic e2e (chapter=1, ktl_storm=5 pre-seeded for dense strikes, auto = always moving, no FAST - the real write path): "static charge window=2.5 dist=0.26" -> "static jolt oil=72.7 push=-0.35" (oil -2 exactly, shove opposite the facing dir) -> storm-V WON. A normal-storm Basalt win fired no window - expected, not a defect: the auto player's ~20s optimal climb only rolls 3-6 strikes at a 35% gate (p(zero windows) ~= 18%); real climbs take minutes. Brace path (freeze = safe): code-read verified (charge_move only accumulates on dir != 0); the headless frozen-keeper run hit a harness anomaly - interact sessions without auto produced ZERO post-begin frames in 150s, solo or uncrowded, while auto runs tick normally (MISTAKES #14) - honest gap, logged, brace e2e deferred. Grade: PASS (hazard path proven end-to-end; brace path code-read + anomaly logged).
Frame: c101-title.png (tower-1 title intact, lamp out) and c101-title-t2.png (chapter-1 title: BASALT boot, three buttons incl. THE COAST) - both eyeballed PASS; the setpiece itself is audio/state, trace-verified above.


## Cycle 102 - THE EMBER SHOAL setpiece: gust squalls + brace path closed (local, gated)
Built (logic-first; PLAN.md restatement first): Ember's gusts now arrive as SQUALLS - first shove, a 1.2s lull telegraphed by a lower answering whistle (pitch 1.15 vs the 1.3 warning), then a stronger REVERSE back-gust at 1.4x the first shove. The counterplay is patience: resuming the climb the instant the first shove passes means walking with the back-gust; holding the brace through the lull costs nothing. Third "read the storm" skill in the gust/static grammar. Data-driven via TOWERS[].squall (0.0 / 0.0 / 1.4 - tower 1 and Basalt untouched). State squall_t/dir/mag armed in the existing gust-hit block, back-gust as its own countdown block, all reset in reset_run. pck 5d75ea6fecde, parts 4 non-empty, reassembly match, check-only clean.
Verified (all via control-ktl.mjs): verify3 WON ok. Ember e2e (chapter=2, auto, won): TWO complete squall pairs on trace - "gust hits dir=-1 v=-0.41" -> "squall gust armed back-dir=1 mag=0.57 lull=1.2" -> "squall back-gust dir=1 v=0.57" (0.41x1.4=0.574 exact) and -0.48 -> 0.67 (0.672 exact): reverse direction and 1.4x magnitude both exact, zero page errors. Tower-1 inert: full win, ZERO squall traces. Basalt brace path CLOSED (the c101 gap): the MISTAKES #14 freeze is headless rAF throttling - a screenshot step restores frames (probe: "door shut" fired only after a shot). Brace run (chapter=1, click begin, screenshot kick, frozen keeper): "static charge window=2.5 dist=0.06" opened on a very near strike, keeper never moved, NO jolt fired - bracing is safe, verified in a real window. The "static out" expiry print was eaten by throttled game time (~5-10x slower than wall; the 4s sleep covered <2.5s game time) - cosmetic trace only, noted honestly. Grade: PASS.
Frames: none new this cycle worth shipping - the mechanics are state/audio; title frames were eyeballed in c101 and are unchanged (tower-1 title intact on this build via verify3's title boot).


## Cycle 103 - the crossing: sailing forward earns a voyage (local, gated)
Built (logic-first; PLAN.md restatement first): the chapter boundary is no longer a teleport. Sailing FORWARD (sel > chapter_get()) opens THE CROSSING: a 14-second passage on a seeded sea - the keeper rows between three lanes while wave crests sweep down; every crest she rides is a splash. The sea is seeded per destination (the sea is the sea, like the seeded layout). The outcome crosses the boundary as real state: 0 splashes = a kind crossing (90 oil), 1-2 = wet (80, the normal start), 3+ = soaked (68), folded into the next run's oil_eff via arrival_oil (session-only like sail_pending - no storage, no guard surface). Chapter banks ON ARRIVAL through the same guarded chapter_set. Sailing BACK stays instant; the debug guarded-sail branch is byte-identical and still first in _on_sail. CrossDraw follows the MapDraw pattern (GDScript-string Control, animated _process + _draw + _gui_input). pck 1a8df3f9, parts 4 non-empty, reassembly match, REAL check-only exit 0.
Verified (all via control-ktl.mjs): verify3 WON ok. Chain e2e (ktl_storm=5 storage, auto, no FAST - the real write path): "hud check map=true cross=true cross_md=true" (new boot guard) -> won -> "coast shown chapter=0 unlocked=1 capstone=true" -> SAIL -> "cross begin to=1 name=THE BASALT WATCH" -> 15 seeded waves, frozen boat mid-lane, exactly the 5 lane-1 waves splashed ("cross splash hits=1..5 lane=1" - collision logic exact) -> "chapter set=1" -> "cross arrived hits=5 oil=68 to=THE BASALT WATCH" (3+ splashes = soaked, rule exact) -> "arrival oil=68" -> "tower boot name=THE BASALT WATCH chapter=1"; the prior run corroborated the carried oil in-game (pane-1 trace oil=71 = 68 + 5 - drain) and won at tower 2. Zero page errors. Steer input: code-read verified (_gui_input sets target_lane, lane lerps) - the harness steer click landed left of the card (x=130 vs control at x~165-315); honest note, click-e2e deferred. Frames eyeballed: c103-crossing.png (boat mid-lane, two crests sweeping, far lamp + progress arc, RIDE THE CALM WATER) and c103-coast.png (map card restored: lit First Light, ring-selected Basalt, dim Ember, BACK/SAIL).
Regression found and fixed mid-cycle (MISTAKES #15): my patch severed mk_map (column-0 insertion), the coast screen stopped rendering, and the RELEASE build failed silently (null.visible skips without aborting - traces stayed green; verify3 doesn't see it). Caught by the frame-eyeball discipline. Fixed, added the boot-time hud-check guard (non-vacuous), un-masked check-only's exit code. Grade: PASS.


## Cycle 104 - THE LAST LIGHT: the voyage's true ending (PASS, local/gated)
The tower-3 capstone was the voyage's end and the game said nothing - every
win closed KEEP IT AGAIN. Now the finale is earned, not added:
- finale_pending (storm V + last chapter + no debug, set in reset_run): at the
  ending transition the other two lights answer on the horizon - warm First
  Light left, cold Basalt right (glow sprites ramping to 0.5) - the ending
  frame holds all three lights. Cold light sits at (95,9,-200): the first
  placement (52,-170) hid behind the tower silhouette; the frame eyeball
  caught it (MISTAKES #15 discipline), one nudge fixed it.
- win_run: finale_now closes the card "...THE SEA QUIETS - THE LIGHTS ALL
  BURN", the button reads SEE THE LIGHTS and opens the all-lit coast;
  finale_set banks ktl_finale guarded like calm_flag_set (debug never banks).
- Title trumps streak/best forever after: "THE LIGHTS ALL BURN - THE VOYAGE
  IS HERS".
Verified (all through control-ktl.mjs): verify3 WON ok (tower-1 inert);
finale e2e twice (storage chapter=2+storm=5, auto, no FAST): "the other
lights answer" -> ending frame eyeballed (both answers visible after the
nudge) -> "finale - the last light held" -> win card trace carries THE
LIGHTS ALL BURN -> SEE THE LIGHTS click -> "coast shown chapter=2
unlocked=2 capstone=true" -> ktl_finale="1" stored. Non-finale regression
(chapter=1+storm=5): won, zero finale traces, ktl_finale null, SEE THE COAST
path byte-untouched. Title e2e (ktl_finale=1): "title finale" trace + frame
(sub carries THE LIGHTS ALL BURN - THE VOYAGE IS HERS). Frames:
c104-ending.png, c104-finale-card.png, c104-coast-lit.png,
c104-title-finale.png.


## Cycle 105 - THE CROSSING steer proof (PARTIAL, local/gated)
Goal: owed steer-click e2e + one measured steering-feel improvement.
LANDED: the steer/settle instrumentation (CrossDraw now reports
steered/settled through signals connected to main.gd prints, so the traces
exist for any working input path), a tap step in control-ktl.mjs, the
crossing card geometry fixed by frame (control spans x~165-312, y~360-452;
click (290,430) = lane 2), and a hardened harness: four full-chain runs
(win -> SEE THE COAST -> SAIL -> cross begin) all reached the crossing
cleanly. BLOCKED: _gui_input on the script-attached CrossDraw never fires
headless - mouse click, touch tap, and motion all vanish while BaseButtons
click fine (MISTAKES #16, 20-min rule hit, escalated to parent). NOT
landed: the feel improvement itself (rate 6.0->7.5 + boat heel, patch ready
in /tmp/c105-feel.py) - held because it cannot be verified until the input
path works. No verify3 this cycle (the change touches only cross-card
reporting + CLI; the B4 run itself exercised boot/climb/coast/cross);
verify3 runs first next cycle. Grade: PARTIAL.


## Cycle 106 - THE CROSSING: input wall cracked, steer proven, feel measured (PASS, local/gated)
The c105 wall broke on instrumentation, not luck. clicklog=1 (the existing
viewport-level param) plus a catch-all "cross ev" trace inside _gui_input
showed the truth: puppeteer input is buffered until a frame ticks, and after
"cross begin" frames stall - a screenshot kick AFTER the click flushes it.
With kick-after-click, _gui_input fires (motion + button both reach it).
STEER E2E (the c104 debt, now paid): full chain (win -> SEE THE COAST ->
SAIL -> cross begin) -> outside click (60,150): ZERO steer traces (the tap
outside the control does not steer) -> inside click (290,430): "cross steer
lane=2" x2 (motion+press) -> "cross lane settled lane=2 ms=396" (BEFORE,
rate 6.0). FEEL: rate 6.0->7.5 + the boat heels into the turn (rotation
(target-lane)*0.4 around its waterline via draw_set_transform, spray stays
world-space). AFTER: settle ms=263 - 34% quicker, measured same harness.
Heel frame: boat renders correctly at lane 2 post-settle; the mid-turn heel
is real in live play but the kick-flush timing only captures post-settle
frames headless - honest note, no fake frame claim. Also fixed mid-cycle:
the c105 signal-lambda prints use "lane=2" (no space) - assert strings must
match exactly. verify3 WON ok after the feel patch. Frames: c106-heel.png,
c106-steer-before.png.


## Cycle 107 - the finale coast beat (PASS, local/gated)
SEE THE LIGHTS landed flat: the all-lit coast just said "THE KEEPER STANDS
HERE". Now the coast itself closes the story: opened from the finale win
card (capstone + last tower + ktl_finale banked), the sub reads "THE
LIGHTS ALL BURN - THE VOYAGE IS HERS" and the keeper's motif plays full
(motif_play(4) - the fourth note exists only at the capstone). Arrival
only: picking another tower restores normal text. Verified through
control-ktl.mjs: finale chain (chapter=2+storm=5) -> "coast finale - the
voyage is hers" + "coast shown capstone=true" + motif notes=4 twice (win
card, then the coast) + frame eyeballed (the line on the card, all three
lights on the map). Regressions: chapter=1+storm=5 capstone coast: zero
beat traces, normal text; title-opened coast unaffected by construction
(from_capstone false). verify3 WON ok. Frames: c107-coast-finale.png,
c107-coast-normal.png.


## Cycle 108 - perf harness + static rain (PASS, local/gated)
Built the measurement first: perf=1 samples Performance.TIME_PROCESS per
frame and prints 5s-window summaries (avg/p95) through control-ktl.mjs.
BEFORE (storm-V auto climb + ending): climb windows 214-585ms avg (n~38,
swiftshader rasterization dominates), ending/win-card windows 116.0 and
99.8ms. The one cut: the exterior rain was an ImmediateMesh cleared and
re-uploaded EVERY frame (600 verts, title + ending phases). Now it is one
static mesh built once (300 streaks, tiled x3/y2 for seamless wrap =
3600 verts) and per frame we scroll the node with two fmods; the ending's
count-thinning became an alpha thin. AFTER on the identical harness:
climb statistically identical (expected - that rebuild never ran there),
ending window 100.3ms vs ~108 before-mean - inside run-to-run noise.
HONEST READ: the delta is unmeasurable through swiftshader distortion
(the wake predicted this); the win is mechanism-level - no per-frame
buffer re-upload on the phone's GPU, where the upload is proportionally
real - plus the perf harness itself, now permanent toolkit. Visual gate:
ending-rain frame eyeballed, streaks identical to the old look, no
regression. verify3 WON ok. Frames: c108-ending-rain.png,
c108-title-rain.png (caught the climb - auto began first).


## Cycle 109 - the daily habit remembers its week (PASS, local/gated)
The daily climb banked only today's best; yesterday's win was forgotten.
Now ktl_daily_log (comma-separated yyyymmdd, cap 31) banks on ANY daily
win, guarded like daily_best_set (debug never banks). daily_streak() works
in day indexes (unix/86400 - month boundaries are one day, not 71),
anchored at today if banked else yesterday (a streak is alive until today
ends unplayed). Surfaces: the title chip adds " - N DAYS RUNNING" (N>=2)
and the daily win card closes with the streak, computed after banking so
today counts. New debug hook: daily=1 makes auto take the daily path -
the daily win is CLI-verifiable for good. Verified through control-ktl.mjs:
seeded log 25,26 + day=20260927 -> "title daily chip best=none streak= 2"
+ chip frame ("TODAY'S CLIMB - 2 DAYS RUNNING"); daily auto win -> "daily
log banked day=20260927 n=3" + card "TODAY'S CLIMB TOOK 0:16 - A NEW
DAILY BEST - 3 DAYS RUNNING - STORM II AWAITS" (frame eyeballed) +
storage grew to 3 days; gap regression (log 24 only) -> streak=0, no line
anywhere. verify3 WON ok. Frames: c109-title-streak.png, c109-daily-win.png.


## Cycle 110 - the crossing finds its water (PASS, local/gated)
The 14-second crossing was the game's quietest stretch - no water under
the boat. Three synthesized additions inside the existing synth pattern,
low and dark per the sound bar: rowwater (3.4s looped low-pass bed with a
slow lap swell, -20, started at cross begin, stopped+freed at arrive),
lap (short falling bloop on steer, throttled 0.3s so a drag cannot
machine-gun), plash (soft splash layered under the gust sfx on wave
hits). Verified through control-ktl.mjs, two chains: run A steered -
"cross water on" -> 2 steer events -> exactly ONE "cross lap lane=2"
(the throttle works) -> "cross arrived hits=3" -> "cross water off";
run B never steered - 5 splashes on the seeded lane-1 waves, each firing
the plash handler ("cross splash h=1..5"), "cross arrived hits=5 oil=68",
water off. Bonus finding: CrossDraw-internal prints DO reach the console
when the frames flow (the c105 silence was input-dispatch only). Audio-
only cycle: honest no-frame note. verify3 WON ok.


## Cycle 111 - coast-map taps, proven end to end (2026-09-27)
PASS. The last unproven input path, with two honest dead ends first.
Grounding catch: a pre-flight read claimed locked-lamp taps were dead
code; the raw source line proved picked.emit sits OUTSIDE the unlocked
guard (three tabs) - no patch needed, _on_coast_pick owns the rejection.
Then two wrong doors: SEE THE COAST on the win card is gated behind a
NON-debug capstone (win_run zeroes held_now under STORM_OVERRIDE/FAST),
so no debug run can reach it there; the reachable debug path is the
title's THE COAST button (needs ktl_chapter>0 in storage). Second miss:
first click at (240,470) fell in the gap between TODAY'S CLIMB and THE
COAST - the title frame fixed it to (240,483). Final chain (storage
ktl_chapter=1, title -> THE COAST -> coast shown chapter=1 unlocked=1):
tap locked lamp 2 (285,378) -> "coast locked pick i=2" + toast THAT
LIGHT IS NOT LIT YET; tap lamp 0 (195,378) -> "coast select i=0
name=THE FIRST LIGHT" + ring move + ITS LIGHT STILL BURNS. Both taps
visible in c111-coast-selected.png (toast + ring + refreshed labels).
verify3 WON ok. Local only, gated.
Frames: c111-title.png, c111-coast-card.png, c111-coast-selected.png


## Cycle 112 PREP (2026-09-27 ~10:19) - optimization baseline + targets
Owner standing directive (relayed by parent 10:17:44 IST, verbatim quote):
heavily optimize, reduce redundancy, improve performance, only the
capabilities the job needs, measure before/after, real numbers.
BASELINE (perf=1, storm=3 auto fast, TIME_PROCESS 5s window):
avg=242.83ms p95=861.5ms (n=39) - swiftshader headless, same-harness
deltas only. Build: index.pck 131,504 bytes.
TARGETS (grounded, line numbers as of 7059536+c111):
1. Storage setters x9 (lines ~2350-2398): near-identical bodies - web
   check + debug guard + JavaScriptBridge.eval localStorage.setItem.
   Unify to one store_set(key, val) helper with the guard inside;
   getters similarly via store_get(key). ~18 redundant guard/eval lines.
2. Card-shell triplication (1131-1135, 1163-1167, 1219-1223): map/cross/
   end cards each rebuild CenterContainer + full-rect dim ColorRect
   (0.02,0.027,0.043,0.55) + PanelContainer + card_style() + min 340.
   Extract mk_card_shell().
3. Clouds loop duplicated (2680, 3169: EXT.clouds iteration).
4. Audit: per-frame work in CrossDraw._process/_draw (embedded source) -
   queue_redraw() every frame while running is needed for motion, but
   check title/menu idle redraw costs.
RULE: behavior must stay identical - refactor only; any behavior change
= FAIL + revert. After: re-run perf=1 same params, report avg/p95 delta
honestly (flat is a valid answer headless), verify3 WON ok, eyeball a
coast + cross + win frame (the three card shells).


## Cycle 112 - leanness pass: dedup x3, measured (2026-09-27)
PASS. Owner optimization directive (verified user WhatsApp 10:17:30,
wamid ...BjMA author=user; parent confirmed 10:19:08).
Landed, behavior identical:
1. mk_card_shell(dim_alpha) + card_shell_finish(sh): the card scaffold
   (center/dim/panel/vbox) was built three times - mk_card (0.35),
   mk_map + mk_cross (0.55). All three now share one builder.
2. store_get(key)/store_set(key, val): 17 web-check + JS eval sites
   collapsed (8 getters, 9 setter/writer sites incl. win_run ktl_best
   and the mute toggle). Debug guards (STORM_OVERRIDE/FAST) stay in the
   callers where they differed; non-web defaults verified identical
   through the "" path.
3. clouds_step(dt): the cloud drift loop was duplicated between the
   title-calm and storm branches of _process.
REAL NUMBERS: main.gd 3218 -> 3195 lines (-23, -145968->144035 bytes);
index.pck 131,504 -> 130,816 bytes (-688). Perf (same harness, perf=1
storm=3 auto fast, TIME_PROCESS 5s windows): before avg=242.83 p95=861.5
(n=39); after window1 avg=268.58 p95=933.21 (n=40), window2 avg=248.47
p95=285.19 (n=38) - FLAT within swiftshader noise, as predicted: these
are size/clarity wins, not hot-path wins. Saying so honestly.
PROOF: REAL check-only exit 0, snapshot ok + reassembly match, verify3
WON ok. Visuals: win card (mk_card) + coast card (mk_map) eyeballed
post-refactor - both pixel-right. mk_cross shell: construction proven
("hud check map=true cross=true cross_md=true") but the crossing overlay
itself was NOT re-eye-balled - sailing back is instant (no crossing) and
a forward crossing needs a real 4+ min capstone run; noted honestly.
Same helper + same params as the verified map shell. Local only, gated.
Frames: c112-win.png, c112-coast.png (kick2), c112-cross.png (tower
interior - kept as the sail-back evidence, not a cross overlay).


## Cycle 113 - a week of light (2026-09-27)
PASS. Seven consecutive daily climbs now get one quiet ceremony: at a
streak that is a multiple of 7, the win-card stats line gains
"A WEEK OF LIGHT" (TWO/THREE/FOUR, then N WEEKS) after DAYS RUNNING.
One touch on the payoff moment only - no new UI, no color, no sound.
Win card reads "- 7 DAYS RUNNING - A WEEK OF LIGHT - STORM II AWAITS"
(c113-milestone.png, eyeballed - sits quiet, on-brand).
Verified both directions through the harness: storage-seeded
ktl_daily_log 21..27 -> daily=1 auto win -> "daily win streak=7" +
"daily milestone weeks=1 streak=7" + frame; seed 22..27 -> "daily win
streak=6" with ZERO milestone traces (negative proven, not assumed).
Debug guards untouched - FAST runs never bank. REAL check-only 0,
snapshot ok + reassembly match, verify3 WON ok. Leanness eye: nothing
worth cutting in the touched code this cycle. Local only, gated.


## Cycle 114 - the door's weight (2026-09-27)
PASS. Parent steer: balcony door polish, visible-in-motion over
audible-once. The entrance door ended flat (0.55s SINE_IN to exactly
0). Now it swings a breath PAST shut (0.5 -> -0.045 over 0.5s, contact
thunk unchanged), the frame throws it back once (-0.045 -> 0 over 0.22s
EASE_OUT), then a soft latch tick (reuses SND.clink at -19/0.85 - no
new synth, leanness eye) + "door latched" trace. 1.07s vs 0.90s: a
beat heavier, deliberate. Verified: "door shut" then "door latched" in
order through the harness; endpoints eyeballed - c114-open.png (leaf
held ajar by dooropen=1) vs c114-shut.png (flush after latch), same
vantage, difference clear. DOORSHUT/DOOROPEN capture semantics
untouched. REAL check-only 0, snapshot ok + reassembly match, verify3
WON ok. One capture lesson: title BEGIN button center is y~441, not
428 - a top-edge graze fails silently (clicklog would have shown it;
first capture run wasted). Local only, gated.
Frames: c114-open.png, c114-shut.png


## Cycle 115 - the silent foghorn, fixed (2026-09-27)
PASS, and not the cycle that was planned. Set out to ADD a calm-sea
title horn; the build caught a duplicate horn_t - a distant-foghorn
mechanism ALREADY existed (40-75s, title/play/relight) but called
sfx("horn") against a stream nobody ever synthesized. sfx() guarded
missing names with a bare return, so the horn was dead on arrival:
traces printed, no sound, every review read it as working. MISTAKES #17.
Fix landed: (1) synthesized SND.horn - low two-tone foghorn (62Hz +
fifth, 0.55s swell, long fade; sound bar kept: synthesized, low, no
harsh highs); (2) sfx() now prints "WARN sfx missing stream" instead of
no-oping silently (owner no-silent-failures rule); (3) NO duplicate
mechanism kept - the existing timer stays the single horn, as the
design intended ("rare and soft - the world beyond the tower").
Verified: fresh title run -> "[KTL] horn" fired (~24s in, first timer),
zero WARN lines (no other dead callers on the title path). verify3 WON
ok. REAL check-only 0, snapshot ok + reassembly match. Audio cycle:
title frame attached for the record; the deliverable is the sound +
the loud guard. Local only, gated.


## Cycle 116 - sweep clean, blind spot closed (2026-09-27)
PASS. Two parts. (1) The MISTAKES #17 sweep: every sfx/loop_sfx name
vs the SND registry, every signal name vs connects/emits, plus a fresh
c112-pattern dup-scan and unused-func sweep - ALL CLEAN (the "chime"
flag was the dynamic chime1-5 prefix; "tpicked" a regex artifact of
\tpicked inside the embedded MapDraw source; zero duplicated 4-line
blocks; engine callbacks _input/_notification excepted). (2) The last
verification debt: mk_cross was shell-refactored blind in c112 because
a forward crossing costs a 4+ min real capstone run. Added a debug-only
cross=1 boot hook (same idiom as the other capture hooks - gated URL
param, CROSSHOOK global, zero behavior change to real runs) that opens
the crossing via the real _on_cross_start entry. Result: overlay
eyeballed post-refactor (c116-cross.png - card shell, sea panel, boat,
wave bands, RIDE THE CALM WATER all correct), steer re-proven through
the hook (cross steer lane=2). Debt closed; the hook stays as the
permanent cheap path. First steer attempt clicked y=470 (below the
panel) - coords read off the fresh frame fixed it (285,405); the
capture lesson rides again. REAL check-only 0, snapshot ok +
reassembly match, verify3 WON ok. Local only, gated.
Frames: c116-cross.png, c116-cross-steer.png

## Cycle 117 - the week of light, acknowledged (2026-09-27)
PASS. The last open candidate from the c112 list: daily_streak() hitting
7 passed with no ceremony. Now the daily chip names it - "TODAY'S CLIMB
- A WEEK OF LIGHT" replaces the day count at streak >= 7 - plus one soft
chime (reused SND.chime1 at -14dB/0.9 pitch, no new synth - leanness
eye) and a "[KTL] week of light streak=N" trace. Build-site placement:
fires once per page load at title build, which is the morning-visit
moment that matters; honest note, it does not re-fire on title re-show
within a session. Verify (all via control-ktl.mjs, RULE 5): seeded
7-day log -> trace fired, chip text on frame (c117-week.png, eyeballed);
seeded 6-day log -> zero week-of-light traces, day count path unchanged;
snapshot ok + reassembly match; verify3 WON ok chimes=5. +5 lines
(3,219 -> 3,223). No perf claim - logic-only change at startup.
Local only, gated.
Frames: c117-week.png, c117-six.png

## Cycle 118 - the crossing light remembers the destination (2026-09-27)
PASS. The crossing's horizon lamp (glow, silhouette, progress arc) was
hardcoded warm (1.0, 0.9, 0.7) - the First Light's tint - even when
rowing to the cold Basalt Watch or the rust Ember Shoal: the one screen
whose subject IS the destination dropped the tower identity. Fix:
LAMP_COLS const (the coast map's three colors) flows through
CrossDraw.begin(seed, col) and tints lamp, glow, and arc. One
substitution point, like every other identity consumer. Debug hook
learned cross=2 so the Ember path is testable (hook condition +
CROSS2 flag parsed in the web block - first attempt referenced q out
of scope, parse error caught by snapshot, fixed). Verify (RULE 5):
cross=1 -> "cross lamp col=(0.62, 0.74, 1, 1)" (Basalt cold);
cross=2 -> "(1, 0.66, 0.45, 1)" (Ember rust); lamp-crop frames
eyeballed - blue vs rust decisive; snapshot ok + reassembly match;
verify3 WON ok chimes=5. +3 lines (3,223 -> 3,226). No perf claim.
Local only, gated (c117 is the live build; this queues for the next
approved deploy).
Frames: c118-cross-basalt.png, c118-cross-ember.png (+ -lamp crops)

## Cycle 119 - one truth for the tower lights (2026-09-27)
PASS. Identity audit first: all nine TOWERS fields have consumers,
application centralized in apply_storm_identity - no dead identity.
The remaining leak was the tower-light colors in THREE places:
LAMP_COLS (c118), the MapDraw embedded string's own copy, and the
finale's "other lights answer" hardcode. Same colors, three sources -
the next identity tweak lands in one and misses two (the c118 bug
shape, dormant). Deduped: MapDraw cols set from LAMP_COLS at build
(empty in-string default - a skipped set fails LOUD in _draw, never a
silent wrong color), the finale loop reads LAMP_COLS[0]/[1]
(value-identical). CrossDraw's in-string warm default stays (separate
script scope, sane tower-1 fallback, caller always passes). Verify
(RULE 5): chapter=1 title names THE BASALT WATCH + offers THE COAST
(frame); click (240,483) -> "coast shown"; coast crop eyeballed -
warm First lit, cold Basalt lit + ring-selected, dim Ember locked,
exactly the canonical colors; snapshot ok + reassembly match; verify3
WON ok chimes=5. Finale answer-lights path not e2e re-run
(value-identical substitution - noted honestly, same standard as the
c112 debt). +1 line (3,226 -> 3,227). No perf claim. Local only,
gated - queues behind c118 for the next approved deploy.
Frames: c119-title-ch1.png, c119-coast.png, c119-coast-crop.png

## Cycle 120 - verification-only: fail card + finale e2e after the dedup (PASS, zero code diff)
Precedent c116: prove the c118/c119 tree end-to-end before it queues for deploy. PLAN.md
restatement + addendum recorded.
- Fail card e2e PASS: manual begin (click 240,442 on the 2-button title + screenshot kick)
  -> "fail card: THE OIL RAN OUT ON THE STAIR - 0 OF 5 PANES LIT". Frame c120-fail.png.
- Finale e2e PASS (c119 debt retired): recipe root-caused first - finale_pending
  (main.gd:2184) requires STORM_OVERRIDE == 0 AND not FAST, so the fast=1 seed I planned
  could never fire the finale; the documented c104 recipe (storage ktl_chapter=2 +
  ktl_storm=5, auto=1, NO fast) is correct as written - ktl_storm is the player's chosen
  level, not the debug override. Detached kick-pump runner (300ms screenshots, rAF is the
  real clock; unlock flags do nothing here, measured 1fps idle): win at ~80s wall.
  Traces in order: "the other lights answer - the voyage is complete" (dedup'd block
  executed, LAMP_COLS[0]/[1] reads clean), "finale - the last light held", win card
  "THE CLIMB TOOK 0:16 - 5 PANES - THE HIGHEST STORM HELD - THE SEA QUIETS - THE LIGHTS
  ALL BURN". ktl_finale banked = 1 (finale_set unblocked, confirming a non-debug run).
  Frame c120-finale.png: lamp lit, finale card THE LIGHT HOLDS, SEE THE LIGHTS button
  (finale_now-only label). Horizon-light pixels are indistinct at 240px behind the modal;
  the LAMP_COLS tints themselves were frame-verified in c118 crops from the same single
  source. Optional eyeball follow-up: SEE THE LIGHTS click -> coast finale beat (c107
  recipe), not debt.
- Headless learnings: zombie chrome stacks from killed calls strangle later runs (ps +
  pkill before any long e2e); detached setsid+nohup runner survives call kills and writes
  status/result files - the pattern for >2min e2e; screenshot pump ~300ms is the sweet
  spot (60ms starves the renderer, 900ms crawls).

## Cycle 121 - the storm-V title keeps its tower (PASS, local/gated)
Fresh-evidence check first (c120 lesson): the c80s audit claim re-proven on the
current build - c121-title-s1-before.png reads clean, c121-title-s5-before.png
loses the shaft/balcony/cap into the crushed sky (dark=0.7, lamp out by design).
Fix: title-only floor on the storm dark factor. apply_storm_identity(lvl,
for_title=false) clamps dark >= 0.82 only at the title call site (2668);
reset_run (2172) keeps the full dark - the storm still eats the sky on the
climb. Shared env self-corrects both directions (both paths re-apply). +2 lines
(3,227 -> 3,229).
Verify (RULE 5): after frames - storm I unchanged (dark=1), IV/V floored
(dark=0.82, traces) with the tower silhouette fully readable
(c121-title-s4/s5-after.png) while the bruised-ember menace holds; auto storm-V
begin prints lvl=5 dark=0.7 (gameplay identity NOT floored); verify3 WON ok
chimes=5. Before/after number: title dark at storm V 0.70 -> 0.82 (gameplay
0.70 unchanged). No perf claim. Local only, queued with c118-c120 for the next
approved deploy.
Frames: c121-title-s1-before.png, c121-title-s5-before.png,
c121-title-s1-after.png, c121-title-s4-after.png, c121-title-s5-after.png

## Cycle 122 - the gallery swing aims at its window (PARTIAL, local/gated)
Three premises hunted with fresh frames first (c120/c121 discipline):
- FALSIFIED: the c86 eye-toast stomp - live run shows the eye at th=14.2 and
  pane 4 at th=15.9, ~4 game-sec clear; frame c122-eye-before.png shows
  THE AIR GOES STILL displayed clean.
- FALSIFIED: the c8x run-start slab occlusion - c122-start-a/b frames show
  the keeper fully readable at the start.
- CONFIRMED (new defect): a four-height frame audit found the gallery-window
  swing (th 6.0) frames dark blank brick at its peak (burst-006) - the
  designed rest moment (big moon, moonlit sea, stars) does not land.
SHIPPED (verified): the swing aim. New vistadebug=1 hook (kept as harness
tooling) unprojects the vista center at zw=1: before (241, 323) on the
480x800 frame, after (241, 382) - center band. Blend 0.55 -> 0.85, aim y
floor+2.3 -> +2.7. verify3 WON ok chimes=5. Frames: burst-006 (before) vs
c122-vista-full.png (after: the window's glow band now centers).
NOT SOLVED (escalated, 20-min rule): the vista TEXTURE quad itself never
renders face-on - only its additive glows (flash/beam/spill, CULL_DISABLED)
are visible; the moon/sea/stars texture is culled. Two orientation
experiments (cull-off, skyq flip) both rendered worse (edge-on slab) and
were reverted. Diagnosis: the window quads' fronts face into the wall
(place_radial convention + the +0.38 bay); the fix needs a group-level
orientation rework, not bisection - and a freeze-camera debug hook to
iterate against (each blind experiment costs ~2 min). Open question logged:
the second zw zone (th 7.6 balcony) shares the same wt aimed at the 6.0
window. +6 lines net (3,229 -> 3,235: aim fix, vistadebug hook).

## Cycle 123 - the gallery vista renders: PlaneMesh faced the ceiling, not the room (PASS, local/gated)
ROOT CAUSE (freeze-camera harness + red-quad bisect): Godot 4 PlaneMesh
defaults to FACE_Y - every window quad lay FLAT (normal +Y, like a floor
slab), not vertical facing +Z as authored. From a level camera the vista
was a zero-area edge-on sliver, backface-culled from slightly below. All
the c122/c123 yaw/bay math chased a phantom: the node's +Z faced the
room correctly (dbg2 qn=(-0.788,0,0.616), dot +0.93 inward); the MESH's
face didn't.
Hunt log: vistahold=1 hook pins keeper th=6.0/y=6.2 and snaps
camTh/camY converged (~45s/iteration). Group-flip and z-negation+PI-flip
reworks both regressed by dbg2 numbers and were reverted. Red bisect:
red + original orientation invisible; red + CULL_DISABLED appeared as a
WHITE band - the storm tint stomps albedo_color every frame
(apply_storm_identity: `for sm in tower.sky_mats: sm.albedo_color = t`),
which is also why no bisect color ever showed. The band was the flat
quad seen edge-on: the giveaway.
FIX (3 lines): pm/fpm/pm2 (vista quad, flash quad, rain quad) get
orientation = PlaneMesh.FACE_Z - fronts now face the room along the
node's +Z. Bisect line removed; vistahold + vistadebug hooks stay as
harness tooling. All four windows share the loop and get the same fix.
VERIFIED: c123-fixed.png vs c123-frozen-snap.png - the window shows the
full vista face-on: stars, rain streaks, big moon, moonlit horizon, ship
light, framed by the L-jamb; the keeper naturally occludes part. dbg2
unchanged (vp r=6.92 inside the wall, qn inward, vis=true). verify3
WON ok chimes=5.
CORRECTS c122's hypothesis: the defect was never aim or brightness - the
texture never faced the room. The c122 aim fix stays valid (the swing
now centers the window on frame).
NOT TOUCHED (future cycles): spill/beam quads were rotated under the
same wrong FACE_Z assumption (the floor spill is vertical); the small
village/ship glow quads (vpm/spm2) are also flat; the balcony door quad
(bpm) likely shares the bug.
3,235 -> 3,242 lines. Local only, queued with c118-c122 for the next
approved deploy.
Frames: c123-frozen-snap.png (before), c123-fixed.png (after),
c123-red3.png / c123-red4.png (bisect evidence)

## Cycle 124 - the window group's remaining quads face the room (PASS, local/gated)
c123 fixed the three big window-cover quads; this cycle finishes the five
the same FACE_Z assumption broke. All PlaneMesh default-FACE_Y victims,
fixed with orientation = PlaneMesh.FACE_Z and NO transform changes (the
authored rotations were right under the FACE_Z mental model):
- dq/dpm sill drips, vq/vpm village hearth glows, sq/spm2 ship light
  (were flat edge-on slivers on the window face),
- spill/spm moonlight floor spill (was a vertical sheet - now flat as
  authored via its rotation.x=-PI/2),
- beam/bm2 moon shaft (now slanted as authored via rotation.x=-1.12).
VERIFIED: freeze frame c124-fixed.png vs c123-fixed.png (same harness,
same pinned pose): the window gains a warm hearth glow on its face and
the floor gains the broad flat moonlight wash from the window; the vista
itself unchanged; nothing else moved. dbg2 unchanged (vp r=6.92, qn
inward, vis=true). verify3 WON ok chimes=5. Honest note: the floor spill
reads bright up close (additive alpha 0.4) - acceptable as moonlight,
tune candidate if the owner finds it strong on the phone.
Balcony door quad (bpm) still open - needs its own th 7.6 freeze audit
(next-cycle candidate). 3,242 lines (in-place edits, net 0). Local only,
queued with c118-c123 for the next approved deploy.
Frames: c123-fixed.png (before), c124-fixed.png (after)

## Cycle 125 - the balcony door opens on the sea, and the swing aims at it (PASS, local/gated)
Two defects, one freeze-harness audit (new vistahold=2 pose pins the
keeper at th 7.6/y 7.62 so the swing converges on the doorway):
- FOUND + FIXED (same FACE_Y family): the balcony door quads bpm/brpm/
  bspm were flat. Red bisect proved it cleanly (bqm is not in sky_mats,
  so no tint stomp - the red quad showed as a thin edge-on LINE at eye
  level, c125-red2.png). orientation = FACE_Z on all three, no transform
  changes: the door vista and its rain face the stair, the landing spill
  lies flat as authored.
- FOUND + FIXED (the c122 open question): the camera swing's aim target
  wt was hard-coded to the th-6.0 gallery window in BOTH zw zones - at
  the balcony the camera twisted back to the old window and the door
  reveal never got framed (before frame: keeper out of shot, wall where
  the door should be). The aim now travels: wt lerps gallery window ->
  balcony door over th 6.0..7.6. Gallery aim at th 6.0 analytically
  unchanged (lerp factor 0) and confirmed by frame.
VERIFIED: c125-before.png (door zone: no keeper, no door, wall) ->
c125-red2.png (edge-on red line = flat quad confirmed) ->
c125-fixed.png (keeper at the threshold, the doorway frames the big
moon and sparkling sea; landing spill glows flat underfoot).
c125-gallery-check.png: the th-6.0 vista unchanged (stars, moon,
horizon, hearth glow, ship light). verify3 WON ok chimes=5.
Harness: vistahold= is now 1=gallery / 2=balcony (was boolean).
3,242 -> 3,246 lines. Local only, queued with c118-c124 for the next
approved deploy.
Frames: c125-before.png, c125-red2.png, c125-fixed.png,
c125-gallery-check.png

## Cycle 126 - the exterior moon, glint road, foam and clouds join the scene (PASS, local/gated)
Full PlaneMesh audit closed the family: 11 interior quads fixed c123-c125,
the lantern sky is a CylinderMesh (fine), the sea is meant to be flat
(fine) - and FIVE exterior uses were the same FACE_Y bug:
- moon disc + halo (no rotation): flat, edge-on, invisible - the title
  had no moon at all.
- moon glint road (rotation.x=-PI/2): a vertical 10x140 sheet in the sea.
- rock foam discs x5 (rotation.x=-PI/2): vertical, not pooled.
- cloud banks x6 (no rotation): flat hairlines.
FIX: orientation = PlaneMesh.FACE_Z at the four construction sites (loops
cover the instances), no transform changes - authored rotations/positions
were right under the FACE_Z mental model.
VERIFIED (title = the exterior scene): c126-before-s1.png (no moon, no
clouds) vs c126-after-s1.png (moon + halo burning low at frame-left,
cloud banks reading across the sky, tower silhouette intact);
c126-after-s5.png confirms the c121 storm-5 title dark floor holds - the
sky stays storm-dark, the moon is a smothered focal glow, the tower
reads as silhouette. verify3 WON ok chimes=5 (needed a zombie-chrome
pkill first - two 115s timeouts were a strangled GPU, not the game).
Honest caveat: the cloud banks read as rectangular slabs at this camera
angle - dark and background, acceptable now, soften candidate if the
owner clocks them on the phone.
The PlaneMesh FACE_Y family is now fully audited: every use in main.gd
classified and either fixed or confirmed intentional.
3,246 lines (in-place edits, net 0). Local only, queued with c118-c125
for the next approved deploy.
Frames: c126-before-s1.png, c126-after-s1.png, c126-before-s5.png,
c126-after-s5.png

## DEPLOY EVENT 2026-09-28 06:04 IST - c118-c126 LIVE
Owner go-live: WhatsApp 5:52:08 "1 go live, 2 go live, 7 provide local
run link" -> WAITING #1 = KTL go-live (mapping verified against the full
progress-report body in the channel record; parent confirmed).
Bridge push: main cd4bca204cb32ac69ce5bd633f1369aa794a5cee (strict
non-force on 24c5a270, 16 blob shas verified bridge-side).
Deploy recipe executed: b64 chunks regenerated from current pck (they
were 7h stale - would have served a stale game) + apply_loader.py
re-applied to index.html BEFORE packaging. Bridge held the push on a
manifest mismatch; local untar+rehash proved the tar clean (mismatch
was bridge-side comparison); full 64-char manifest sent; push proceeded.
Post-deploy verification: all 16 artifacts fetched live are byte-
identical to the deploy manifest; live-rendered title (moon + halo +
cloud banks through the split-pack chunk path) and live-rendered
gallery vista (auto run to th 6.0, keeper at the window, stars/moon/
sea/ship light) both confirmed. Live = local = c126. Queue cleared.

## Cycle 127 - the small windows' moon and glint stop being rectangles (PASS, local)
The first post-deploy full-run audit (3 frames: th 2.2 / 9.4 / 14.2, all
clean gameplay) flagged one suspect: a bright white-purple slab near the
th-15.0 small window. Hunt with the new vistahold=3 freeze pose (pins
the keeper at th 15.0):
- The audit slab = the window's lightning-flash quad mid-strike (fq,
  additive, alpha follows flashV) - INTENDED art, correctly room-facing
  post-FACE_Z. Falsified as a defect, logged.
- The REAL defect underneath: tex_skywin baked a hard 18x18 white square
  (the moon) and a hard 28x70 glint column, invisible while the quad was
  flat - face-on they read as rendering bugs. First feather attempt
  failed honestly: the window material is OPAQUE, so writing falloff
  into texture ALPHA did nothing (alpha ignored) - the rectangles just
  changed shape. Fix: lerp the RGB toward the sky/sea base color instead
  (smoothstep moon disc, edge-feathered glint column).
VERIFIED: c127-win15.png (before: two hard white rectangles in the
window) -> c127-fixed2.png (after: soft moon disc, glint column melts
into the sea, village hearth glow soft at its base). All three small
windows (th 1.6, 10.9, 15.0) share tex_skywin and get the fix. The
gallery vista texture is untouched. verify3 WON ok chimes=5.
Harness: vistahold= now 1=gallery / 2=balcony / 3=th-15.0 window.
LEARNING logged (MISTAKES #22): alpha writes into an opaque material's
albedo texture are a no-op - feather by lerping RGB, and when a "visual
fix" changes nothing, check whether the channel you wrote is even read.
3,246 -> 3,257 lines. Local only - live is c126; this queues for the
next owner-approved deploy.
Frames: c127-slab.png, c127-flash.png, c127-win15.png (before),
c127-fixed.png (alpha attempt, still hard), c127-fixed2.png (after)

## Cycle 128 - lamp-room approach audited clean in real play; floor spill pooled (PASS, local)
Two parts:
1. AUDIT (lamp-room approach, last unaudited segment): the vistahold=4
   frozen pose (th 18.5, camTh snapped) produced an alarming frame -
   giant featureless foreground plane, keeper occluded. Verified against
   REAL PLAY before patching (c120-c122 discipline): auto-run captures
   at th 18.0 ("THE LAST PANE": keeper on the storm-exposed walkway,
   reads well) and th 18.8 ("THE LENS IS WHOLE": the lamp room reveal -
   glass panes, brass mullions, lens rings inside) both compose
   correctly. The frozen-pose weirdness was a harness artifact of
   snapping camTh/camY where the at_top camera lerps r to 4.1 - the
   player never sees it. Clean audit, logged; harness note: freeze
   frames are for geometry bugs, not for judging lerp-driven camera
   composition.
2. SHIPPED: the gallery floor spill 0.4 -> 0.26 alpha. The additive
   pool blew the already lamp-lit floor to white up close (flagged in
   the c124/c126 reports). c128-spill.png vs c124-fixed.png: the floor
   keeps its moonlight pool but the lamp's warm circle reads around the
   keeper again and floor boards survive.
VERIFIED: verify3 WON ok chimes=5. 3,257 -> 3,259 lines. Local only -
live is c126; queues with c127 for the next owner-approved deploy.
Frames: c128-approach.png (harness artifact, documented), c128-top-a.png,
c128-top-b.png (real-play audit), c128-spill.png (after)

---

## c129 — cloud softening + all-storms title audit (calm wake #1, 9/28)

### Problem restatement
1. Cloud banks read as hard-edged rectangles in the night sky (mat_glow is unshaded dark slabs).
2. Title backdrop only eyeballed at storm 1 (s2-s5 unverified).

### What changed (main.gd)
- Cloud loop: `cm2.albedo_texture = tower.glow_tex`. mat_glow has alpha 0.85 (< 1.0) so TRANSPARENCY_ALPHA is already on; the radial glow texture now fades each slab's edges in texture space — no material transparency changes, no new flags (learned from MISTAKES #22: opaque mats ignore alpha, but this one was already transparent).
- No title/audit patch needed — audit returned clean.

### Verification (rule 5, frozen build + verify3)
- c129-title-s1..s5.png — 480x800 title captures at storms 1-5 (fresh build, 10:53): PASS on all five. Clouds soft in every storm, no hard rectangles; moon disc + glint intact (s1, s4); s2/s3 clean; s5 dark floor holds.
- verify3 e2e: 85s, WON ok, chimes=5.

### Grade: PASS
