# AssetLib submission form: Stylized 2D VFX Lite

Fill in at https://godotengine.org/asset-library/asset/submit once the repository is public and pushed. Account, push and submission are done by us, not yet done.

| Field | Value |
| --- | --- |
| Asset Name | Stylized 2D VFX Lite |
| Category | 2D Tools (Addons). Alternative: Shaders |
| Godot version | 4.4 (tested with 4.4.1; the project and scene files are saved by 4.4) |
| Version | 1.0.0 |
| Repository host | GitHub |
| Repository URL | https://github.com/REEBO0/godot-stylized-2d-vfx-lite |
| Issues URL | https://github.com/REEBO0/godot-stylized-2d-vfx-lite/issues |
| Download Commit | <commit after push> |
| Icon URL | https://raw.githubusercontent.com/REEBO0/godot-stylized-2d-vfx-lite/main/icon.png |
| License | MIT |
| Preview 1 (image) | https://raw.githubusercontent.com/REEBO0/godot-stylized-2d-vfx-lite/main/docs/effects.png (thumbnail: same URL) |
| Preview 2 (image) | https://raw.githubusercontent.com/REEBO0/godot-stylized-2d-vfx-lite/main/docs/explosion_small.png (thumbnail: same URL) |
| Preview 3 (image) | https://raw.githubusercontent.com/REEBO0/godot-stylized-2d-vfx-lite/main/docs/hit_spark.png (thumbnail: same URL) |

Previews use PNG because the form takes image or YouTube URLs and the thumbnail is computed from them; the animated docs/preview.gif is shown in the README.

## Description (plain text)

Stylized 2D VFX Lite is a set of four ready-to-use 2D effects for Godot 4: hit spark, slash arc, small explosion and coin pickup.

Every effect is a scene made from canvas_item shaders and GPUParticles2D, so the shapes stay sharp at any size and no sprite sheets are needed. Recolour an effect with its tint property, speed it up or slow it down, and flip slashes with a negative scale.

What is inside:
- hit_spark: white-gold flash, plus twinkle, thin ring and fast sparks.
- slash_arc: steel-blue crescent with a hot edge and a stringy tail.
- explosion_small: flash, toon fireball, lingering smoke, shockwave and embers.
- coin_pickup: gold ring, twinkle, rising glints and a dot burst.

Usage:
const HIT := preload("res://addons/reeboo_fx2d/effects/hit_spark.tscn")
var fx := ReebooFx2D.spawn(HIT, self, global_position)
fx.impact.connect(func(strength: float) -> void: print("shake the camera by ", strength))

Effects free themselves when they finish. The impact signal fires on the impact frame, which is handy for camera shake, hit-stop or a sound. The finished signal fires when the effect ends.

Install: the effects are copied to addons/reeboo_fx2d/. No plugin needs enabling. Works with the Forward+, Mobile and Compatibility renderers. Tested with Godot 4.4.1.

The repository also holds a demo scene and headless tests, which are left out of the AssetLib download.

The full Stylized 2D VFX pack has 26 effects: https://reeboolabs.itch.io/stylized-2d-vfx-godot
More from REEBOO Labs: https://reeboolabs.com/

MIT licensed. Copyright (c) 2026 REEBOO Labs.
