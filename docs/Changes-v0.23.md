# v0.23 — Soundtrack and interface polish

## Original soundtrack

Three original 16-bar cues replace the former four-second drone:

- **Embers at the Forge** — preparation; 76 BPM, 50.53-second loop.
- **Oathbound** — combat; 100 BPM, 38.4-second loop.
- **The Crown Splinters** — phase II; 112 BPM, 34.29-second loop.

Plucked strings, glass bells, warm sustained harmonies, bass and low percussion develop a D-minor theme. No external recordings, samples or existing songs were used. The deterministic composition source and Ogg masters are included, with CC0 terms in the soundtrack README. Wrapped room tails keep the loops continuous. Two music players crossfade in linear gain when the encounter state changes.

Audio starts with the first browser click/key. Music and effects have independent volume controls and an all-sound mute, saved on this device. Zero volume is fully muted. Current-track and mute status appear in the footer. Display and advanced bus controls remain available.

## Interface

A shared theme now covers menus, the forge, encounter review, battle controls, dialogs, filters, sliders, tooltips and Balance Workshop. It adds original pixel chamber framing, proper serif headings, warmer gold accents, consistent panel depth, stronger primary actions, visible keyboard focus, clearer input fields and slimmer scrollbars.

Face cards separate name, category/timing and a brief effect; their full hover preview, selection/removal and drag placement remain. Boss turn headings use short names so they fit. Patch topics use a scroll list instead of compressing every historical entry into a tiny button.

The pixel battlefield and original sprites remain. Ability descriptions remain hover-only. No combat values, targeting rules or gameplay RNG changed. Bu’gh’s balance remains provisional; the v0.22.2 trial report is historical. The Windows build remains unchanged.

## Validation

The 29-script regression pass succeeded. The final presentation suite adds 17 focused checks. The presentation checks cover all 48 cards, readable card/focus styles, three complete looping cues, state-driven transitions, independent sliders, both-bus mute, unchanged gameplay RNG and the scrollable patch list. Existing gameplay and interface regression coverage is retained. The ability-choice layout regression also passes 1,486 checks after compact-dialog spacing was adjusted.

The actual browser export is tested in Chromium/WebGL, including the face-picker-to-encounter flow and combat. Web Audio output is measured after a real click: audible output, silence at Music 0, restored music after raising it, and zero output under all-sound mute. Browser script/page errors are checked. The rulebook and PDF describe the new presentation and audio controls.
