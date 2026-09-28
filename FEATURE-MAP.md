
# FEATURE-MAP - KEEP THE LIGHT (every user-facing feature, code location, verification status)

Verification habit: every cycle that touches a feature re-verifies its row on the exported build with traces/frames; history in CYCLES.md.

## Core loop
| Feature | Where in main.gd | Status |
|---|---|---|
| Title screen + best-time memory | title card (~line 1220-1260), ktl_best read (~1923) | VERIFIED live (c87 first-run, c91 persistence) |
| Climb (left stick / WASD / arrows) | _input ScreenDrag stick (~1775), keys (~1729) | VERIFIED (c83 fix, c87, c89) |
| Jump + stair gaps | press_jump (~1548), gap table (~line 17-19) | VERIFIED (c89 gap jump) |
| Two-finger touch peek (right half) | _input ScreenTouch/Drag peek_id (~1756-1777) | VERIFIED (c94, phone portrait) |
| Desktop drag-peek | InputEventMouseMotion + mouse_lb (~1768) | VERIFIED (c95; works live, hardening added) |
| Pane pickups x5 + lens | pane_pos_list (~78), pickup (~2322-2352) | VERIFIED (c95 trace: slots 1.4/7.1/9.7/16.6/18.1) |
| Oil drops (+8s) | drop_pos_list (~91), pickup (~2355) | VERIFIED (c89) |
| Oil burn + low-oil warning | ST.oil drain, "THE OIL IS LOW" toast | VERIFIED (c88 fail path) |
| Fail card + TRY AGAIN | fail flow (~1906) | VERIFIED (c88, c90 restart, c95) |
| Win card + KEEP IT AGAIN | win flow (~1963-1996) | VERIFIED (c79, c92, c95) |
| Storm progression I-V + capstone prestige | storm level (~1969), capstone block | VERIFIED (c92: held=1, calm=1, reset to I) |
| Eye-of-the-storm stillness beat | storm_h dip (~2039), eyeSeen (~2288) | VERIFIED (c86; pane slot moved clear in c95) |

## Atmosphere
| Feature | Where | Status |
|---|---|---|
| Lantern light + sconce warm-up | build_sconces (~925) | VERIFIED (c86/c87 frames) |
| Storm identity per level (tint/dark/gust) | storm identity trace, storm table | VERIFIED (c81, c86) |
| Thunder/lightning | lightning cadence, flash (FLASHHOLD debug) | VERIFIED (c82) |
| Tower groan (high storms) | groan voice (GROANHOLD debug) | VERIFIED (c75 trace, audio-only) |
| Balcony vista + sea + ship light | vista build, ship (SHIPZ debug) | VERIFIED (c76, c78) |
| Wind/gust/creak synthesized audio | sfx system, gust (GUSTHOLD debug) | VERIFIED traces; audio-only cycles logged honestly |

## Persistence + safety
| Feature | Where | Status |
|---|---|---|
| Best time (ktl_best) | ~1923/1963-1968 | VERIFIED + GUARDED (c91 found, c95 fixed) |
| Storm streak (ktl_storm/held/calm) | ~1932-1961 | VERIFIED guarded (c91, c92) |
| Mute (ktl_mute) + mute chip | ~1662/1689, chip UI | VERIFIED (c82) |
| Pause chip + ESC | toggle_pause, chips | VERIFIED (c82, c85) |
| Debug params (storm=, fast=, startoil=, holds) | _ready param parse (~1552) | VERIFIED; never write storage (c91/c95) |

## Web surface (fleet standards)
| Standard | Where | Status |
|---|---|---|
| Favicon | index.icon.png, apple-touch-icon | OK (pre-existing) |
| Title "KEEP THE LIGHT" | index.html head | OK |
| Meta description + theme-color | index.html head | FIXED c93 |
| Branded 404 (LOST IN THE STORM) | 404.html | FIXED c93, live-verified |
| Friendly loader error state (no stack traces) | displayFailureNotice via apply_loader.py | FIXED c93, frame-verified |
| Split-pack loader (4 b64 parts) | index.html loader via apply_loader.py | VERIFIED live (deploy 2026-09-26) |


## Cycle 104 - THE LAST LIGHT finale
User POV: hold storm V at THE EMBER SHOAL (the last tower) and the voyage
closes: two distant lights answer on the horizon during the ending, the win
card ends "THE LIGHTS ALL BURN", SEE THE LIGHTS opens the all-lit coast, and
every later title visit reads "THE LIGHTS ALL BURN - THE VOYAGE IS HERS".
CLI-drive: interact --params auto=1 --storage '{"ktl_chapter":"2","ktl_storm":"5"}'
-> waitTrace "the other lights answer" / "finale - the last light held" /
"win card" (carries THE LIGHTS ALL BURN) -> click [240,451] -> waitTrace
"coast shown"; --read-storage ktl_finale. Regression: chapter=1+storm=5 ->
grab finale == empty, ktl_finale null. Title: --storage '{"ktl_finale":"1"}'
-> waitTrace "title finale".


## Cycle 106 - crossing steer e2e (the recipe)
Steering is now CLI-verifiable: interact --params auto=1&clicklog=1
--storage '{"ktl_chapter":"0","ktl_storm":"5"}' -> win -> click [240,451] ->
coast shown -> click [270,466] -> cross begin -> shot (kick) -> click
[x,y]. RULE: a screenshot kick must FOLLOW any click that targets a custom
Control - puppeteer input buffers until a frame ticks, and frames stall
once the crossing card is up. Control rect on the 480x800 shot: x[165,312]
y[360,452]; lane thirds of its width. Asserts: "cross steer lane=N" (no
space), "cross lane settled lane=N ms=M". Current feel: settle 263ms
(rate 7.5); outside clicks produce zero steer traces.


## Cycle 107 - the finale coast beat
User POV: win storm V at the last tower, tap SEE THE LIGHTS, and the coast
card itself closes the voyage: "THE LIGHTS ALL BURN - THE VOYAGE IS HERS"
plus the full four-note motif. CLI-drive: storage chapter=2+storm=5, auto
win, click SEE THE LIGHTS -> "coast finale - the voyage is hers". Beat
conditions: capstone open + last tower + ktl_finale banked; every other
coast path is unchanged.


## Cycle 108 - perf=1 harness + static rain
perf=1 param: prints "[KTL] perf window n= avg= p95= ms" every 5s of game
time (Performance.TIME_PROCESS - logic+driver ms, transfers to phone
better than wall fps). CLI: wait-settle --params auto=1&storm=5&perf=1
--trace won --grab "perf window". Swiftshader caveat: rasterization
dominates headless numbers; only same-harness deltas mean anything.
The exterior rain is a static tiled mesh scrolled via EXT.rain_mi.position
(two fmods per frame); do not reintroduce per-frame ImmediateMesh rebuilds.


## Cycle 109 - daily week streaks
User POV: win TODAY'S CLIMB on consecutive days and the habit shows: the
title chip says "TODAY'S CLIMB - N DAYS RUNNING" and the daily win card
closes with the streak. A gap day breaks it. Storage: ktl_daily_log
(comma-separated yyyymmdd, cap 31, banked on any daily win, debug-guarded).
CLI-drive: --storage '{"ktl_daily_log":"20260925,20260926"}' --params
auto=1&daily=1&day=20260927 (daily=1 is the debug hook making auto take
the daily path) -> "daily log banked" / "daily win streak=" / win card.


## Cycle 110 - crossing water audio
User POV: the crossing now sounds like water - a low bed under the boat,
a hull lap when you steer, a soft plash when a wave catches you. All
synthesized, all quiet. CLI-drive: chain to cross begin -> "cross water
on"; kick-flushed steer click -> "cross lap lane=N" (0.3s throttle);
no-steer run -> "cross splash h=N" per hit; arrive -> "cross water off".
