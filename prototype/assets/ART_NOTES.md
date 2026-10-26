# Pixel art · v0.13

All three heroes now use armoured knight sprites and helmet icons, with teal, purple and gold tabards / shields. Cinder Brand and Ember Burst fire is drawn as animated pixel rectangles without touching gameplay RNG.

The current art uses original pixel maps and geometric tiles defined in `tools/make_pixel_art.py`. The generator draws the sprites at their source resolution; it does not convert or downsample the previous painted images.

- `pixel_boss_phase2.png`: a separate hand-drawn 32×32 burning-crown boss for phase II. Ember rings, sparks and fire are procedural effects; none consumes gameplay RNG.
- `pixel_units.png`: 32×32 cells, Vesper / Rook above Wren / The Hollow.
- `pixel_portraits.png`: separate 16×16 head icons in the same order.
- `pixel_arena.png`: 179×179 pixels, with nine 19-pixel tiles per side and a four-pixel border. Displayed at exactly 4× scale.

Godot uses nearest-neighbour texture sampling. The painted arena and portraits have been removed from the game assets.

The arena remains the same 9×9 logical board. Decorative cracks and moss do not block movement. Existing font and template licences still apply to their separate assets.
