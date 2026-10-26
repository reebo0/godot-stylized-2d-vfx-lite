extends SceneTree
## REEBOO Stylized 2D VFX - smoke test. Run: godot --headless --path . -s res://tests/smoke_test.gd
## Loads every effect, plays two of each at the same time (one tinted, at 2x speed), stops the loops, and checks that every
## one-shot emits impact + finished and frees itself. Prints SMOKE TEST PASSED or SMOKE TEST FAILED.

const FX_DIR := "res://addons/reeboo_fx2d/effects/"

var impacts := 0
var finished_count := 0


func _initialize() -> void:
	_run()


func _run() -> void:
	var root2d := Node2D.new()
	get_root().add_child(root2d)
	var names: Array[String] = []
	for f in DirAccess.get_files_at(FX_DIR):
		var n := f.trim_suffix(".remap")
		if n.ends_with(".tscn"):
			names.append(n.get_basename())
	names.sort()
	var fails: Array[String] = []
	var live: Array = []
	var loops := 0
	var shots := 0
	var expect_impacts := 0
	for n in names:
		var scene := load(FX_DIR + n + ".tscn") as PackedScene
		if scene == null:
			fails.append("load " + n)
			continue
		for k in 2:
			var fx := ReebooFx2D.spawn(scene, root2d, Vector2(100 + 40 * k, 100), 0.3 * k, Color(1, 0.8, 0.6) if k == 1 else Color.WHITE)
			if k == 1:
				fx.speed = 2.0
			fx.impact.connect(func(_s: float) -> void: impacts += 1)
			fx.finished.connect(func() -> void: finished_count += 1)
			live.append(weakref(fx))
			if fx.looping:
				loops += 1
			else:
				shots += 1
				if fx.impact_strength > 0.0:
					expect_impacts += 1
	await create_timer(1.6).timeout
	for w in live:
		var fx = w.get_ref()
		if fx and fx.looping:
			fx.stop()
	await create_timer(2.4).timeout
	var alive := 0
	for w in live:
		if w.get_ref():
			alive += 1
	if alive != 0:
		fails.append("%d effects still alive" % alive)
	if finished_count != live.size():
		fails.append("finished %d of %d" % [finished_count, live.size()])
	if impacts < expect_impacts:
		fails.append("impacts %d < %d" % [impacts, expect_impacts])
	print("SMOKE effects=%d instances=%d one_shot=%d looping=%d impacts=%d finished=%d alive_after=%d renderer=%s" % [
		names.size(), live.size(), shots, loops, impacts, finished_count, alive, RenderingServer.get_current_rendering_method()])
	print("SMOKE TEST PASSED" if fails.is_empty() else "SMOKE TEST FAILED: " + ", ".join(fails))
	quit(0 if fails.is_empty() else 1)
