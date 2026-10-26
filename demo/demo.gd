extends Node2D
## REEBOO Stylized 2D VFX - demo. Press F5.
## Left/Right: browse   Space: replay   Mouse click: spawn the effect at the mouse   A: auto-play on/off
## T: cycle tint colours   B: light/dark background   F: flip slashes left/right   Esc: quit

signal effect_spawned(effect_name: String, fx: ReebooFx2D)

const FX_DIR := "res://addons/reeboo_fx2d/effects/"
const FULL_PACK_EFFECTS := 26
const FULL_PACK_URL := "https://reeboolabs.itch.io/stylized-2d-vfx-godot"
## Effects whose origin is the ground line (feet), the rest are centred on the target.
const GROUND := ["ground_slam", "land_dust", "heal_burst", "level_up", "powerup_pickup"]
const AIR := ["double_jump", "dash_streak"]
const TINTS := [Color.WHITE, Color(1.0, 0.55, 0.55), Color(0.6, 1.0, 0.7), Color(0.6, 0.75, 1.0), Color(1.0, 0.85, 0.4)]
const GROUND_Y := 540.0
const TARGET := Vector2(640, 410)

var names: Array[String] = []
var index := 0
var auto := true
var light := false
var flip := false
var tint_i := 0
var current: ReebooFx2D
var record_mode := false
var show_ui := true
var trauma := 0.0
var _shake_t := 0.0
var _auto_wait := 0.0
var _spawn_at := Vector2.INF
@onready var cam := Camera2D.new()
@onready var label := Label.new()


func _ready() -> void:
	for f in DirAccess.get_files_at(FX_DIR):
		var n := f.trim_suffix(".remap")
		if n.ends_with(".tscn"):
			names.append(n.get_basename())
	names.sort()
	cam.position = Vector2(640, 360)
	add_child(cam)
	var ui := CanvasLayer.new()
	add_child(ui)
	label.position = Vector2(16, 12)
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	label.add_theme_constant_override("outline_size", 6)
	ui.add_child(label)
	var args := {}
	for a in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		args[kv[0]] = kv[1] if kv.size() > 1 else "1"
	if args.has("bg"):
		light = args["bg"] == "light"
	if args.has("zoom"):
		cam.zoom = Vector2.ONE * float(args["zoom"])
	if args.has("cam_x"):
		cam.position.x = float(args["cam_x"])
	if args.has("cam_y"):
		cam.position.y = float(args["cam_y"])
	if args.has("ui"):
		show_ui = args["ui"] == "1"
	if args.has("tint"):
		tint_i = int(args["tint"]) % TINTS.size()
	if args.has("flip"):
		flip = args["flip"] == "1"
	if args.has("x"):
		_spawn_at = Vector2(float(args["x"]), float(args.get("y", "410")))
	if args.has("also"):
		# extra effects for scene captures: name:x:y:seconds, comma separated
		for item in str(args["also"]).split(","):
			var p := item.split(":")
			var sc := load(FX_DIR + p[0] + ".tscn") as PackedScene
			var where := Vector2(float(p[1]), float(p[2]))
			get_tree().create_timer(float(p[3])).timeout.connect(func() -> void:
				var e := ReebooFx2D.spawn(sc, self, where, 0.0, TINTS[tint_i])
				e.impact.connect(_on_impact))
	if args.has("fx"):
		record_mode = true
		auto = false
		index = maxi(names.find(args["fx"]), 0)
		get_tree().create_timer(float(args.get("at", "0.066"))).timeout.connect(play_current)
	else:
		play_current()
	label.visible = show_ui
	queue_redraw()


func spawn_point(n: String) -> Vector2:
	if n in GROUND:
		return Vector2(TARGET.x, GROUND_Y)
	if n in AIR:
		return Vector2(TARGET.x, GROUND_Y - 110)
	return TARGET


func play_current(at := Vector2.INF) -> void:
	if names.is_empty():
		return
	var n := names[index]
	var scene := load(FX_DIR + n + ".tscn") as PackedScene
	if current and is_instance_valid(current) and current.looping:
		current.stop()
	if at == Vector2.INF and _spawn_at != Vector2.INF:
		at = _spawn_at
	var pos := spawn_point(n) if at == Vector2.INF else at
	current = ReebooFx2D.spawn(scene, self, pos, 0.0, TINTS[tint_i])
	if flip:
		current.scale.x = -1.0
	current.impact.connect(_on_impact)
	_auto_wait = (2.6 if current.looping else current.duration + 0.5)
	effect_spawned.emit(n, current)
	_update_label()


func _on_impact(strength: float) -> void:
	trauma = clampf(trauma + strength * 0.6, 0.0, 1.0)


func _update_label() -> void:
	var n := names[index]
	var fx := current
	label.text = "%s   (%d / %d)   %s\nLeft/Right browse   Space replay   Click spawn   A auto %s   T tint   B background   F flip   Esc quit" % [
		n, index + 1, names.size(), "looping: stop() ends it" if fx.looping else "one-shot %.2f s" % fx.duration, "on" if auto else "off"]
	if names.size() < FULL_PACK_EFFECTS:
		label.text += "\nFree sample: %d of %d effects. Full pack: %s" % [names.size(), FULL_PACK_EFFECTS, FULL_PACK_URL]


func _process(delta: float) -> void:
	if trauma > 0.0:
		trauma = maxf(trauma - delta * 1.6, 0.0)
		_shake_t += delta * 30.0
		var s := trauma * trauma
		cam.offset = Vector2(14.0 * s * sin(_shake_t * 1.7), 9.0 * s * sin(_shake_t * 2.3))
	else:
		cam.offset = Vector2.ZERO
	if auto and not record_mode:
		_auto_wait -= delta
		if _auto_wait <= 0.0:
			index = (index + 1) % names.size()
			play_current()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		play_current(get_global_mouse_position())
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_RIGHT:
				index = (index + 1) % names.size()
				play_current()
			KEY_LEFT:
				index = (index - 1 + names.size()) % names.size()
				play_current()
			KEY_SPACE:
				play_current()
			KEY_A:
				auto = not auto
				_update_label()
			KEY_T:
				tint_i = (tint_i + 1) % TINTS.size()
				play_current()
			KEY_B:
				light = not light
				queue_redraw()
			KEY_F:
				flip = not flip
				play_current()
			KEY_ESCAPE:
				get_tree().quit()


func _draw() -> void:
	# Sky
	var top := Color("#d9ecf7") if light else Color("#14122b")
	var bottom := Color("#fbf3e4") if light else Color("#2b2350")
	var bands := 24
	for i in bands:
		var t := float(i) / bands
		draw_rect(Rect2(-200, -200 + t * 760, 1680, 760.0 / bands + 1), top.lerp(bottom, t))
	# Hills (two layers)
	for layer in 2:
		var pts := PackedVector2Array()
		var base := GROUND_Y - 60.0 + layer * 30.0
		for x in range(-200, 1500, 20):
			pts.append(Vector2(x, base - 70.0 * (0.6 - 0.3 * layer) * (1.0 + sin(x * 0.006 + layer * 2.0)) - 20.0 * sin(x * 0.017 + layer)))
		pts.append(Vector2(1500, 900))
		pts.append(Vector2(-200, 900))
		var c := (Color("#b9d8c6") if layer == 0 else Color("#9fc7ae")) if light else (Color("#2c2a5a") if layer == 0 else Color("#3a3468"))
		draw_colored_polygon(pts, c)
	# Ground
	draw_rect(Rect2(-200, GROUND_Y, 1700, 400), Color("#c9b48f") if light else Color("#1d1a33"))
	draw_rect(Rect2(-200, GROUND_Y, 1700, 8), Color("#a68e68") if light else Color("#4a4380"))
	# Target post
	draw_rect(Rect2(TARGET.x - 7, TARGET.y + 30, 14, GROUND_Y - TARGET.y - 30), Color("#8a6a4a") if light else Color("#5a4a6a"))
	var rings := [Color("#e9e1d3"), Color("#d2504a"), Color("#e9e1d3"), Color("#d2504a")]
	for i in rings.size():
		draw_circle(TARGET, 44.0 - i * 11.0, rings[i] if light else rings[i].darkened(0.35))
