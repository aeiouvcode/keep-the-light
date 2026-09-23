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

Next cycle candidates (in priority order):
1. Distinct tint + pickup chime per pane (chime/chime2/chime3 exist, reuse
   by index), HUD shows pane silhouettes filling.
2. Level-2 balcony vista: a door gap in the tower wall at the second landing
   framing moon + sea (cheap: wall segment skip + railing).
3. Title-screen motion: slow camera drift on the stair column.
4. Pause menu with controls recap (Esc / touch button).
