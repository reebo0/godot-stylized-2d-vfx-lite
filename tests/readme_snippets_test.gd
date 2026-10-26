extends SceneTree
## Runs the code snippets of README.md (Usage) as written. Run: godot --headless --path . -s res://tests/readme_snippets_test.gd

const HIT := preload("res://addons/reeboo_fx2d/effects/hit_spark.tscn")


func _initialize() -> void:
	_run()


func _run() -> void:
	var game := Node2D.new()
	get_root().add_child(game)
	# Snippet 1: spawn a one-shot at a position (it frees itself).
	var fx := ReebooFx2D.spawn(HIT, game, Vector2(200, 120))
	var got := [false, false]
	fx.impact.connect(func(strength: float) -> void: got[0] = strength > 0.0)
	fx.finished.connect(func() -> void: got[1] = true)
	# Snippet 2: add as a child, recolour, flip, play again later.
	var fx2 := HIT.instantiate() as ReebooFx2D
	fx2.tint = Color(0.6, 0.8, 1.0)
	fx2.scale.x = -1.0
	game.add_child(fx2)
	await create_timer(1.2).timeout
	var ok: bool = got[1] and not is_instance_valid(fx) and not is_instance_valid(fx2)
	print("README SNIPPETS %s (finished=%s, freed=%s)" % ["OK" if ok else "FAILED", got[1], not is_instance_valid(fx)])
	quit(0 if ok else 1)
