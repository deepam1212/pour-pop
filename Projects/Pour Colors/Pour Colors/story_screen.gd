class_name StoryScreen
extends HouseScreen
# Story (train-track map) screen.


# train-track map
const STEP = 150.0              # distance between two levels on the map

const TRACK_Y0 = 15300.0        # world y of level 1

const WORLD_H = 15650.0

const T_MIN = -1.5

const T_MAX = 100.0

const HOP_TIME = 1.0

var hop_wait: float = 0.0

var man_from: int = 0

var man_to: int = 0

var man_u: float = 0.0

var man_t: float = 0.0

var land_t: float = 0.0

# garden decorations
var trees: Array = []

var bushes: Array = []

var flowers: Array = []

var ponds: Array = []

var butterflies: Array = []

# ---------------------------------------------------------------- track map

func track_pos(t: float) -> Vector2:
	return Vector2(360.0 + 180.0 * sin(t * 0.8), TRACK_Y0 - t * STEP)

func track_tan(t: float) -> Vector2:
	return Vector2(180.0 * 0.8 * cos(t * 0.8), -STEP).normalized()

func track_x_at_y(y: float) -> float:
	var t: float = (TRACK_Y0 - y) / STEP
	return 360.0 + 180.0 * sin(t * 0.8)

func center_cam(t: float):
	cam_y = clampf(track_pos(t).y - SCREEN_H * 0.55, 0.0, MAP_MAX_CAM)
	cam_vel = 0.0
	cam_follow = false

func go_menu():
	screen = "menu"
	selected = -1
	won = false
	confetti.clear()
	hop_state = "none"
	man_t = float(unlocked - 1)
	center_cam(man_t)
	fade = 0.8

# after finishing a level: show the map, wait a moment, hop to the next level,
# then start it automatically
func begin_hop():
	screen = "menu"
	selected = -1
	won = false
	confetti.clear()
	fade = 0.8
	man_from = current_level - 1
	man_to = current_level
	man_t = float(man_from)
	man_u = 0.0
	hop_wait = 0.0
	hop_state = "wait"
	center_cam(man_t)
	cam_follow = true

func update_map(delta: float):
	match hop_state:
		"wait":
			man_t = float(man_from)
			hop_wait += delta
			if hop_wait >= 0.6:
				hop_state = "hop"
				man_u = 0.0
				play_sfx("jump")
		"hop":
			man_u = minf(1.0, man_u + delta / HOP_TIME)
			man_t = lerpf(float(man_from), float(man_to), smooth(man_u))
			if man_u >= 1.0:
				hop_state = "land"
				land_t = 0.0
				play_sfx("land")
		"land":
			man_t = float(man_to)
			land_t += delta
			if land_t >= 0.9:
				hop_state = "none"
				start_level(current_level + 1)
				return

	if cam_follow:
		var target: float = clampf(track_pos(man_t).y - SCREEN_H * 0.55, 0.0, MAP_MAX_CAM)
		cam_y = lerpf(cam_y, target, minf(1.0, delta * 5.0))
	elif not press_active and absf(cam_vel) > 8.0:
		cam_y += cam_vel * delta
		cam_vel *= exp(-4.0 * delta)
		if cam_y <= 0.0 or cam_y >= MAP_MAX_CAM:
			cam_vel = 0.0
		cam_y = clampf(cam_y, 0.0, MAP_MAX_CAM)

func near_pond(x: float, y: float, mx: float, my: float) -> bool:
	for item in ponds:
		var p: Dictionary = item
		if absf(x - float(p["x"])) < mx and absf(y - float(p["y"])) < my:
			return true
	return false

func clear_of_track(x: float, y: float, margin: float) -> bool:
	for dy in [-120.0, -60.0, 0.0, 60.0]:
		var d: float = dy
		if absf(x - track_x_at_y(y + d)) < margin:
			return false
	return true

func init_garden():
	var rng := RandomNumberGenerator.new()
	rng.seed = 12345
	# ponds on the side away from the track
	for k in 7:
		var py: float = 700.0 + k * 2100.0 + rng.randf_range(-300.0, 300.0)
		var tx: float = track_x_at_y(py)
		var px: float = 105.0 if tx > 360.0 else 615.0
		ponds.append({"x": px, "y": py, "rx": 80.0, "ry": 50.0})
	var tries: int = 0
	while trees.size() < 150 and tries < 3000:
		tries += 1
		var x: float = rng.randf_range(20.0, 700.0)
		var y: float = rng.randf_range(150.0, WORLD_H - 60.0)
		if not clear_of_track(x, y, 135.0):
			continue
		if near_pond(x, y, 130.0, 100.0):
			continue
		trees.append({"x": x, "y": y, "s": rng.randf_range(0.8, 1.25),
			"k": rng.randi_range(0, 2), "ph": rng.randf() * TAU})
	tries = 0
	while bushes.size() < 90 and tries < 2000:
		tries += 1
		var bx: float = rng.randf_range(20.0, 700.0)
		var by: float = rng.randf_range(150.0, WORLD_H - 40.0)
		if not clear_of_track(bx, by, 95.0):
			continue
		bushes.append({"x": bx, "y": by, "s": rng.randf_range(0.7, 1.2)})
	tries = 0
	while flowers.size() < 520 and tries < 4000:
		tries += 1
		var fx: float = rng.randf_range(10.0, 710.0)
		var fy: float = rng.randf_range(100.0, WORLD_H - 20.0)
		if not clear_of_track(fx, fy, 55.0):
			continue
		if near_pond(fx, fy, 100.0, 70.0):
			continue
		flowers.append({"x": fx, "y": fy, "ph": rng.randf() * TAU,
			"col": COLORS[rng.randi_range(0, COLORS.size() - 1)]})
	for k in 7:
		butterflies.append({"x": rng.randf_range(80.0, 640.0), "y": rng.randf_range(220.0, 1000.0),
			"ph": rng.randf() * TAU, "col": COLORS[rng.randi_range(0, 7)]})

# ---------------------------------------------------------------- the man (urban look)

# foot = where his feet are, air = 0 standing .. 1 tucked in mid-jump
func draw_man(foot: Vector2, air: float, bob: float):
	var s: float = 0.95
	draw_set_transform(foot + Vector2(0.0, bob), 0.0, Vector2(s, s))
	var skin := Color(0.96, 0.78, 0.62)
	var jacket := Color(0.12, 0.15, 0.28)
	var pants := Color(0.07, 0.08, 0.16)
	var neon := Color(0.35, 0.92, 1.0)
	var dark := Color(0.2, 0.12, 0.1)

	var hip := Vector2(0, -52)
	var lf: Vector2 = Vector2(-11, 0).lerp(Vector2(-14, -24), air)
	var rf: Vector2 = Vector2(11, 0).lerp(Vector2(16, -30), air)
	draw_capsule(hip + Vector2(-8, 0), lf, 14.0, pants)
	draw_capsule(hip + Vector2(8, 0), rf, 14.0, pants)
	draw_circle(lf, 8.0, Color(0.92, 0.94, 1.0))
	draw_circle(rf, 8.0, Color(0.92, 0.94, 1.0))

	draw_capsule(Vector2(0, -56), Vector2(0, -88), 36.0, jacket)
	draw_line(Vector2(0, -92), Vector2(0, -58), neon, 3.0, true)
	draw_line(Vector2(-16, -70), Vector2(16, -70), Color(neon.r, neon.g, neon.b, 0.6), 3.0)

	var lh: Vector2 = Vector2(-30, -58).lerp(Vector2(-40, -118), air)
	var rh: Vector2 = Vector2(30, -58).lerp(Vector2(40, -118), air)
	draw_capsule(Vector2(-18, -84), lh, 11.0, jacket)
	draw_capsule(Vector2(18, -84), rh, 11.0, jacket)
	draw_circle(lh, 7.0, skin)
	draw_circle(rh, 7.0, skin)

	var hc := Vector2(0, -112)
	draw_circle(hc, 23.0, skin)
	# dark cap with a neon brim
	var cap := PackedVector2Array()
	for k in range(0, 13):
		var a: float = PI + PI * float(k) / 12.0
		cap.append(hc + Vector2(cos(a) * 25.0, -4.0 + sin(a) * 25.0))
	draw_colored_polygon(cap, Color(0.10, 0.12, 0.22))
	draw_rect(Rect2(hc.x - 2.0, hc.y - 9.0, 34.0, 7.0), neon)
	# face
	draw_circle(hc + Vector2(-8, 6), 3.2, dark)
	draw_circle(hc + Vector2(8, 6), 3.2, dark)
	if air > 0.2:
		draw_circle(hc + Vector2(0, 16), 4.5, Color(0.6, 0.1, 0.1))
	else:
		draw_arc(hc + Vector2(0, 11), 7.0, 0.3, PI - 0.3, 10, dark, 2.5, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func draw_man_on_map():
	var base_world: Vector2 = track_pos(man_t)
	var ground: Vector2 = base_world - Vector2(0.0, cam_y) + Vector2(62.0, 24.0)
	var air: float = 0.0
	var h: float = 0.0
	var bob: float = 0.0
	if hop_state == "hop":
		air = sin(PI * man_u)
		h = 170.0 * air
	elif hop_state == "none" or hop_state == "wait":
		bob = sin(time_acc * 3.0) * 3.0
	draw_colored_polygon(ellipse_pts(ground, 34.0 - 10.0 * air, 12.0 - 3.0 * air, 16), Color(0.35, 0.92, 1.0, 0.18))
	draw_colored_polygon(ellipse_pts(ground, 28.0 - 10.0 * air, 10.0 - 3.0 * air, 16), Color(0, 0, 0, 0.35))
	draw_man(ground - Vector2(0.0, h), air, bob)
	if hop_state == "land":
		var p: float = clampf(land_t / 0.9, 0.0, 1.0)
		draw_arc(ground, 20.0 + p * 110.0, 0.0, TAU, 32, Color(0.5, 0.95, 1.0, 1.0 - p), 5.0, true)
		for k in 6:
			var a: float = float(k) / 6.0 * TAU
			var sp: Vector2 = ground + Vector2(cos(a), sin(a) * 0.5) * (30.0 + p * 90.0) + Vector2(0, -20.0 * p)
			draw_sparkle(sp, 9.0 * (1.0 - p), Color(0.8, 1, 1, 1.0 - p))

# ---------------------------------------------------------------- ground (neon night)

func draw_garden_ground():
	# 0 = start of the map (teal dusk), 1 = far end (deep violet night)
	var prog: float = clampf(cam_y / MAP_MAX_CAM, 0.0, 1.0)
	# cam_y is large at level 1, so invert: near level 1 -> teal, near level 100 -> violet
	var far: float = 1.0 - prog
	var top: Color = Color(0.03, 0.09, 0.17).lerp(Color(0.05, 0.03, 0.17), far)
	var bot: Color = Color(0.04, 0.20, 0.25).lerp(Color(0.11, 0.06, 0.30), far)
	draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(SCREEN_W, 0),
		Vector2(SCREEN_W, SCREEN_H), Vector2(0, SCREEN_H)]),
		PackedColorArray([top, top, bot, bot]))

	# soft aurora glows
	var ac1: Color = Color(0.10, 0.80, 0.75).lerp(Color(0.65, 0.30, 1.0), far)
	var ac2: Color = Color(0.20, 0.90, 0.55).lerp(Color(0.20, 0.55, 1.0), far)
	for k in 6:
		var fk: float = 1.0 - float(k) * 0.16
		draw_circle(Vector2(140.0 + 60.0 * sin(time_acc * 0.25), 330.0), 340.0 * fk, Color(ac1.r, ac1.g, ac1.b, 0.028))
		draw_circle(Vector2(600.0 + 50.0 * cos(time_acc * 0.2), 880.0), 320.0 * fk, Color(ac2.r, ac2.g, ac2.b, 0.028))

	# faint dot grid that scrolls with the map
	var gstep: float = 64.0
	var gfirst: int = floori(cam_y / gstep)
	for gy in range(gfirst, gfirst + 22):
		var yy: float = float(gy) * gstep - cam_y
		for gx in 12:
			draw_circle(Vector2(float(gx) * gstep + 30.0, yy), 1.3, Color(1, 1, 1, 0.07))

	# moonlit ponds
	for item in ponds:
		var pd: Dictionary = item
		var c := Vector2(float(pd["x"]), float(pd["y"]) - cam_y)
		if c.y < -120.0 or c.y > SCREEN_H + 120.0:
			continue
		var rx: float = float(pd["rx"])
		var ry: float = float(pd["ry"])
		for k in 4:
			draw_colored_polygon(ellipse_pts(c, rx + 14.0 + k * 8.0, ry + 14.0 + k * 8.0, 28), Color(0.2, 0.8, 1.0, 0.04))
		draw_colored_polygon(ellipse_pts(c, rx + 4.0, ry + 4.0, 28), Color(0.35, 0.85, 1.0, 0.55))
		draw_colored_polygon(ellipse_pts(c, rx, ry, 28), Color(0.03, 0.10, 0.24))
		draw_colored_polygon(ellipse_pts(c + Vector2(-10, -6), rx * 0.62, ry * 0.5, 24), Color(0.10, 0.35, 0.6, 0.55))
		# moon reflection
		draw_colored_polygon(ellipse_pts(c + Vector2(14, -4), 14.0, 5.0, 12), Color(1, 1, 0.9, 0.5 + 0.2 * sin(time_acc * 2.0)))
		var rp: float = fposmod(time_acc * 0.5 + float(pd["x"]) * 0.01, 1.0)
		var ring: PackedVector2Array = ellipse_pts(c, rx * rp, ry * rp, 24)
		ring.append(ring[0])
		draw_polyline(ring, Color(0.6, 0.95, 1.0, 0.5 * (1.0 - rp)), 2.0, true)

	# glowing flowers
	for item in flowers:
		var f: Dictionary = item
		var sy: float = float(f["y"]) - cam_y
		if sy < -20.0 or sy > SCREEN_H + 20.0:
			continue
		var fx: float = float(f["x"])
		var sway: float = sin(time_acc * 1.5 + float(f["ph"])) * 2.5
		var head := Vector2(fx + sway, sy - 12.0)
		draw_line(Vector2(fx, sy), head, Color(0.05, 0.25, 0.25), 2.0)
		var fcol: Color = f["col"]
		var pulse: float = 0.6 + 0.4 * sin(time_acc * 2.0 + float(f["ph"]) * 3.0)
		draw_circle(head, 13.0, Color(fcol.r, fcol.g, fcol.b, 0.10 * pulse))
		draw_circle(head, 7.0, Color(fcol.r, fcol.g, fcol.b, 0.20 * pulse))
		draw_circle(head, 3.2, fcol.lightened(0.35))

	# dark shrubs with a soft rim light
	for item in bushes:
		var bd: Dictionary = item
		var by: float = float(bd["y"]) - cam_y
		if by < -60.0 or by > SCREEN_H + 60.0:
			continue
		var bx: float = float(bd["x"])
		var bs: float = float(bd["s"])
		draw_colored_polygon(ellipse_pts(Vector2(bx, by + 2.0), 38.0 * bs, 9.0 * bs, 12), Color(0, 0, 0, 0.3))
		draw_circle(Vector2(bx - 18.0 * bs, by - 12.0 * bs), 20.0 * bs, Color(0.04, 0.17, 0.20))
		draw_circle(Vector2(bx + 18.0 * bs, by - 12.0 * bs), 20.0 * bs, Color(0.04, 0.17, 0.20))
		draw_circle(Vector2(bx, by - 22.0 * bs), 24.0 * bs, Color(0.05, 0.22, 0.25))
		draw_arc(Vector2(bx, by - 22.0 * bs), 24.0 * bs, PI * 1.1, PI * 1.7, 10, Color(0.3, 0.9, 0.85, 0.45), 2.0, true)

func draw_tree(x: float, sy: float, s: float, kind: int, ph: float):
	var sway: float = sin(time_acc * 1.2 + ph) * 2.0 * s
	draw_colored_polygon(ellipse_pts(Vector2(x, sy), 40.0 * s, 12.0 * s, 14), Color(0, 0, 0, 0.3))
	draw_rect(Rect2(x - 7.0 * s, sy - 55.0 * s, 14.0 * s, 58.0 * s), Color(0.10, 0.07, 0.14))
	if kind == 1:
		# dark pines with a cold rim light
		var pine := Color(0.04, 0.16, 0.19)
		for j in 3:
			var w: float = (52.0 - j * 12.0) * s
			var yb: float = sy - (30.0 + j * 34.0) * s
			var shift: float = sway * float(j + 1) / 3.0
			var col: Color = pine if j % 2 == 0 else pine.lightened(0.08)
			var tip := Vector2(x + shift * 1.4, yb - 56.0 * s)
			draw_colored_polygon(PackedVector2Array([
				Vector2(x - w + shift, yb), Vector2(x + w + shift, yb), tip]), col)
			draw_line(Vector2(x - w + shift, yb), tip, Color(0.35, 0.95, 0.9, 0.55), 2.0, true)
	else:
		var c1 := Color(0.04, 0.20, 0.22)
		var c2 := Color(0.07, 0.30, 0.30)
		var rim := Color(0.35, 0.95, 0.85, 0.5)
		if kind == 2:
			# glowing violet trees
			c1 = Color(0.22, 0.08, 0.38)
			c2 = Color(0.40, 0.16, 0.62)
			rim = Color(1.0, 0.5, 0.95, 0.6)
			draw_circle(Vector2(x + sway, sy - 95.0 * s), 78.0 * s, Color(0.8, 0.3, 1.0, 0.07))
		draw_circle(Vector2(x + sway, sy - 100.0 * s), 46.0 * s, c1)
		draw_circle(Vector2(x - 30.0 * s + sway, sy - 72.0 * s), 34.0 * s, c1)
		draw_circle(Vector2(x + 30.0 * s + sway, sy - 72.0 * s), 34.0 * s, c1)
		draw_circle(Vector2(x - 14.0 * s + sway, sy - 112.0 * s), 24.0 * s, c2)
		draw_circle(Vector2(x - 36.0 * s + sway, sy - 82.0 * s), 16.0 * s, c2)
		draw_arc(Vector2(x + sway, sy - 100.0 * s), 46.0 * s, PI * 1.05, PI * 1.6, 12, rim, 2.5, true)

func draw_garden_trees():
	for item in trees:
		var t: Dictionary = item
		var sy: float = float(t["y"]) - cam_y
		if sy < -40.0 or sy > SCREEN_H + 160.0:
			continue
		draw_tree(float(t["x"]), sy, float(t["s"]), int(t["k"]), float(t["ph"]))

# (name kept) twinkling stars + drifting mist instead of cartoon clouds
func draw_screen_clouds():
	var prog: float = clampf(cam_y / MAP_MAX_CAM, 0.0, 1.0)
	var sa: float = 1.0 - prog * 0.65
	for item in stars:
		var sd: Dictionary = item
		var tw: float = 0.5 + 0.5 * sin(time_acc * 1.6 + float(sd["ph"]))
		draw_circle(Vector2(float(sd["x"]), float(sd["y"]) * 1.4), float(sd["s"]) * (0.5 + 0.5 * tw),
			Color(1, 1, 1, (0.15 + 0.5 * tw) * sa))
	for k in 3:
		var mx: float = fposmod(time_acc * (6.0 + k * 2.0) + k * 340.0, 1200.0) - 240.0
		var my: float = 420.0 + k * 340.0
		draw_colored_polygon(ellipse_pts(Vector2(mx, my), 300.0, 46.0, 20), Color(0.55, 0.85, 1.0, 0.045))

# (name kept) glowing fireflies instead of butterflies
func draw_butterflies():
	for item in butterflies:
		var b: Dictionary = item
		var ph: float = float(b["ph"])
		var p := Vector2(float(b["x"]) + 90.0 * sin(time_acc * 0.6 + ph),
			float(b["y"]) + 60.0 * sin(time_acc * 0.9 + ph * 2.0))
		var bc: Color = b["col"]
		var col: Color = Color(0.85, 1.0, 0.55).lerp(bc, 0.25)
		var pulse: float = 0.5 + 0.5 * sin(time_acc * 3.0 + ph * 4.0)
		draw_circle(p, 18.0, Color(col.r, col.g, col.b, 0.06 + 0.06 * pulse))
		draw_circle(p, 9.0, Color(col.r, col.g, col.b, 0.18 + 0.15 * pulse))
		draw_circle(p, 3.0, Color(1, 1, 0.9, 0.7 + 0.3 * pulse))

# dark ballast, glowing neon rails; the part you already travelled glows gold
func draw_track():
	var t_lo: float = maxf(T_MIN, (TRACK_Y0 - (cam_y + SCREEN_H + 160.0)) / STEP)
	var t_hi: float = minf(T_MAX, (TRACK_Y0 - (cam_y - 160.0)) / STEP)
	if t_hi <= t_lo:
		return
	var bed := PackedVector2Array()
	var rail_a := PackedVector2Array()
	var rail_b := PackedVector2Array()
	var done_a := PackedVector2Array()
	var done_b := PackedVector2Array()
	var sleepers: Array = []
	var t: float = floorf(t_lo * 10.0) / 10.0
	var t_done: float = float(unlocked - 1)
	while t <= t_hi:
		var p: Vector2 = track_pos(t) - Vector2(0.0, cam_y)
		var tg: Vector2 = track_tan(t)
		var nrm := Vector2(-tg.y, tg.x)
		bed.append(p)
		rail_a.append(p + nrm * 15.0)
		rail_b.append(p - nrm * 15.0)
		if t <= t_done:
			done_a.append(p + nrm * 15.0)
			done_b.append(p - nrm * 15.0)
		if roundi(t * 10.0) % 2 == 0:
			sleepers.append([p + nrm * 28.0, p - nrm * 28.0])
		t += 0.1
	if bed.size() < 2:
		return
	draw_polyline(bed, Color(0.35, 0.85, 1.0, 0.07), 104.0, true)
	draw_polyline(bed, Color(0.02, 0.03, 0.09, 0.92), 78.0, true)
	draw_polyline(bed, Color(0.09, 0.11, 0.21, 0.95), 62.0, true)
	for item in sleepers:
		var sp: Array = item
		draw_line(sp[0], sp[1], Color(0.20, 0.23, 0.38), 7.0)
	# neon rails
	var neon := Color(0.35, 0.92, 1.0)
	draw_polyline(rail_a, Color(neon.r, neon.g, neon.b, 0.16), 14.0, true)
	draw_polyline(rail_b, Color(neon.r, neon.g, neon.b, 0.16), 14.0, true)
	draw_polyline(rail_a, neon, 4.0, true)
	draw_polyline(rail_b, neon, 4.0, true)
	# travelled part in gold
	var gold := Color(1.0, 0.80, 0.30)
	if done_a.size() >= 2:
		draw_polyline(done_a, Color(gold.r, gold.g, gold.b, 0.2), 14.0, true)
		draw_polyline(done_b, Color(gold.r, gold.g, gold.b, 0.2), 14.0, true)
		draw_polyline(done_a, gold, 4.0, true)
		draw_polyline(done_b, gold, 4.0, true)
	draw_polyline(rail_a, Color(1, 1, 1, 0.45), 1.5, true)
	draw_polyline(rail_b, Color(1, 1, 1, 0.45), 1.5, true)

# glassy dark node with a neon ring (open), emerald glow (done), dim (locked)
func draw_station(p: Vector2, idx: int):
	var open: bool = idx < unlocked
	var done: bool = idx < completed
	var r: float = 40.0
	draw_circle(p + Vector2(0, 10), r + 6.0, Color(0, 0, 0, 0.4))
	if open:
		var col: Color = Color(0.25, 0.92, 0.62) if done else COLORS[idx % COLORS.size()]
		for k in 4:
			draw_circle(p, r + 8.0 + float(k) * 7.0, Color(col.r, col.g, col.b, 0.07))
		draw_circle(p, r + 4.0, col.lightened(0.2))
		draw_circle(p, r, Color(0.05, 0.06, 0.15))
		draw_circle(p + Vector2(0, -r * 0.35), r * 0.62, Color(1, 1, 1, 0.05))
		draw_arc(p, r - 7.0, 0.0, TAU, 40, Color(col.r, col.g, col.b, 0.4), 3.0, true)
		text_c(str(idx + 1), p.y + 14.0, 38, Color.WHITE, p.x - 60.0, 120.0)
		if done:
			draw_check(p + Vector2(31, -31), 13.0)
		elif idx == unlocked - 1:
			var pulse: float = 0.5 + 0.5 * sin(time_acc * 3.5)
			draw_arc(p, r + 14.0 + 6.0 * pulse, 0.0, TAU, 40, Color(1, 0.9, 0.45, 0.35 * (1.0 - pulse)), 3.0, true)
			var ang: float = time_acc * 1.8
			for k in 3:
				var a0: float = ang + float(k) * TAU / 3.0
				draw_arc(p, r + 16.0, a0, a0 + 1.2, 12, Color(1.0, 0.9, 0.45), 4.0, true)
	else:
		draw_circle(p, r + 3.0, Color(0.30, 0.33, 0.50, 0.6))
		draw_circle(p, r, Color(0.06, 0.07, 0.15, 0.94))
		draw_icon_lock(p, 50.0, Color(1, 1, 1, 0.4))

# darkens the edges of the map for depth
func draw_vignette():
	var a := Color(0.02, 0.01, 0.08, 0.75)
	var s := Color(0.02, 0.01, 0.08, 0.55)
	var z := Color(0.02, 0.01, 0.08, 0.0)
	draw_polygon(PackedVector2Array([Vector2(0, SCREEN_H - 380.0), Vector2(SCREEN_W, SCREEN_H - 380.0),
		Vector2(SCREEN_W, SCREEN_H), Vector2(0, SCREEN_H)]), PackedColorArray([z, z, a, a]))
	draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(130, 0),
		Vector2(130, SCREEN_H), Vector2(0, SCREEN_H)]), PackedColorArray([s, z, z, s]))
	draw_polygon(PackedVector2Array([Vector2(SCREEN_W - 130.0, 0), Vector2(SCREEN_W, 0),
		Vector2(SCREEN_W, SCREEN_H), Vector2(SCREEN_W - 130.0, SCREEN_H)]), PackedColorArray([z, s, s, z]))

func draw_map():
	draw_garden_ground()
	draw_screen_clouds()
	draw_track()

	var i_lo: int = maxi(0, floori((TRACK_Y0 - (cam_y + SCREEN_H + 120.0)) / STEP))
	var i_hi: int = mini(TOTAL_LEVELS - 1, ceili((TRACK_Y0 - (cam_y - 120.0)) / STEP))
	for idx in range(i_lo, i_hi + 1):
		draw_station(track_pos(float(idx)) - Vector2(0.0, cam_y), idx)

	draw_garden_trees()
	draw_butterflies()
	draw_vignette()

	# sleek header: fade, spaced title, gold divider, progress bar
	var h0 := Color(0.02, 0.01, 0.09, 0.92)
	var h1 := Color(0.02, 0.01, 0.09, 0.0)
	draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(SCREEN_W, 0),
		Vector2(SCREEN_W, 200), Vector2(0, 200)]), PackedColorArray([h0, h0, h1, h1]))
	text_c("M A G I C   S O R T", 80.0, 50, Color(0.96, 0.97, 1.0))
	var gold := Color(1.0, 0.80, 0.35)
	draw_line(Vector2(190, 100), Vector2(340, 100), Color(gold.r, gold.g, gold.b, 0.6), 2.0, true)
	draw_line(Vector2(380, 100), Vector2(530, 100), Color(gold.r, gold.g, gold.b, 0.6), 2.0, true)
	draw_sparkle(Vector2(360, 100), 9.0, gold)
	var frac: float = clampf(float(completed) / float(TOTAL_LEVELS), 0.0, 1.0)
	draw_capsule(Vector2(210, 134), Vector2(510, 134), 10.0, Color(1, 1, 1, 0.12))
	if frac > 0.0:
		var fx: float = 210.0 + 300.0 * frac
		draw_capsule(Vector2(210, 134), Vector2(fx, 134), 10.0, Color(0.25, 0.9, 0.95))
		draw_capsule(Vector2(210, 134), Vector2(fx, 134), 4.0, Color(1, 1, 1, 0.55))
	text_c("LEVEL " + str(unlocked) + " / " + str(TOTAL_LEVELS), 172.0, 22, Color(1, 1, 1, 0.75))

	# coin counter and daily reward button
	draw_home_extras()
