extends Node2D

const COLORS = [
	Color(0.93, 0.26, 0.30),   # red
	Color(0.20, 0.52, 0.96),   # blue
	Color(0.25, 0.80, 0.40),   # green
	Color(0.98, 0.84, 0.20),   # yellow
	Color(0.98, 0.58, 0.16),   # orange
	Color(0.62, 0.40, 0.90),   # purple
	Color(0.20, 0.85, 0.88),   # cyan
	Color(0.98, 0.40, 0.70),   # pink
	Color(0.60, 0.38, 0.22),   # brown
	Color(0.92, 0.92, 0.96),   # white
]
const CAPACITY = 4
const LIFT = 30.0
const SCREEN_W = 720.0
const BASE_H = 1280.0
var SCREEN_H: float = 1280.0
var extra_h: float = 0.0
var top_pad: float = 60.0

# levels and ads
const TOTAL_LEVELS = 200

# links used by the settings screen. Leave a URL empty "" to show the
# built-in text page instead (privacy / terms) or to do nothing (rate).
const PRIVACY_URL = ""
const TERMS_URL = ""
const RATE_URL = ""
const SUPPORT_EMAIL = "deepamsharma668@gmail.com"
const APP_VERSION = "1.0.0"

# bottom tab bar
const TAB_COLORS = [
	Color(0.20, 0.85, 0.80),   # story
	Color(0.40, 0.55, 1.00),   # settings
]
const LB_UNLOCK_LEVEL = 20      # leaderboard opens after this many levels
const WIN_DELAY_AVATAR = 4.4
const TAB_BAR_COL = Color(0.04, 0.05, 0.14)

# built-in text pages. REPLACE these with your real legal text.
const DOC_PRIVACY = "Last updated: October 30, 2026\n\nPour Pop does not collect, store or share any personal information.\n\nThe game has no accounts, no ads, no in-app purchases and no analytics or tracking tools.\n\nYour game progress and settings are saved only on your device. They are never sent to us or to any third party. Deleting the app removes this data.\n\nWe do not sell personal data or share it with third parties.\n\nPour Pop does not collect personal information from anyone, including children under 13.\n\nIf our practices change, we will update this policy.\n\nQuestions? Contact Deepam Sharma at deepamsharma668@gmail.com"
const DOC_TERMS = "Last updated: October 30, 2026\n\nBy installing or playing Pour Pop you agree to these terms.\n\n1. License: Deepam Sharma grants you a personal, non-exclusive, non-transferable license to use the game for your own non-commercial entertainment.\n\n2. You may not copy, modify, sell, redistribute or reverse engineer the game, or use it for any unlawful purpose.\n\n3. Your progress and settings are stored only on your device. Deleting the app removes them.\n\n4. The game is provided \"as is\" without warranties. To the extent permitted by law, we are not liable for indirect or consequential losses, loss of progress, or problems caused by your device.\n\n5. We may update these terms or the game at any time. Continuing to play means you accept the changes.\n\nContact: deepamsharma668@gmail.com"
const DOC_ABOUT = "Pour Pop is a relaxing color-sorting puzzle.\n\nPour liquids, sand and gas between the bottles until every bottle holds just one color.\n\n100 levels are waiting for you, from easy to tricky.\n\nThank you for playing!"

# train-track map
const STEP = 150.0              # distance between two levels on the map
const TRACK_Y0 = 30300.0        # world y of level 1
const WORLD_H = 30650.0
const MAP_MAX_CAM = 29370.0     # WORLD_H - SCREEN_H
const T_MIN = -1.5
const T_MAX = 200.0
const HOP_TIME = 1.0

# bottle shape (all bottles are the same size)
const TUBE_W = 96.0
const NECK_W = 66.0
const BODY_H = 272.0
const SHOULDER_H = 36.0
const NECK_H = 46.0
const TUBE_H = BODY_H + SHOULDER_H + NECK_H
const GAP = 20.0
const BOTTLE_RADIUS = 30.0
const TUBE_BORDER = 5.0
const SHOULDER_STEPS = 10
const ARC_STEPS = 8

# 3D look
const SURFACE_RY = 9.0
const MOUTH_RY = 8.0

# pouring
const POUR_H = 55.0
const T_IN = 0.45
const T_OUT = 0.45

# effects
const FX_TIME = 1.3
const WIN_DELAY = 2.4

# boss levels (every 10th level)
const BOSS_INTRO_TIME = 2.2

var tubes: Array = []
var start_state: Array = []
var selected: int = -1
var history: Array = []
var won: bool = false
var win_timer: float = 0.0
var win_wait: float = 2.4
var win_new_part: int = -1       # part unlocked by the level just won (-1 = none)
var reveal_t: float = 0.0

# my house
var house_done: int = 0          # how many house jobs are finished
var house_choice: Array = []     # option picked for each finished job
var house_items: Dictionary = {}
var house_clean: Array = [false, false, false, false, false, false]
var house_sel: int = -1          # option being previewed
var house_fx_t: float = -10.0
var house_fx_pos := Vector2.ZERO
var house_fx_slot: int = 0
var house_fx_clean: bool = false
var house_text_cache: String = ""
var house_lines: Array = []
var house_clean_rect := Rect2(210, 925, 420, 100)
var house_place_rect := Rect2(170, 1052, 380, 56)
var toast_text: String = ""
var toast_t: float = 0.0

var boss_intro_t: float = 0.0

# what the bottles hold on this level: "liquid", "sand" or "gas"
var fill_kind: String = "liquid"

# screens and progress
# screen: "menu" (story map), "play", "ad", "leaderboard", "settings", "doc"
var screen: String = "menu"
var current_level: int = 1
var unlocked: int = 1
var completed: int = 0

# settings
var sound_on: bool = true
var music_on: bool = true

# ads

# buttons
var menu_rect := Rect2(30, 40, 90, 90)
var undo_rect := Rect2(150, 1100, 170, 110)
var restart_rect := Rect2(400, 1100, 170, 110)
var tab_rect := Rect2(180, 1128, 360, 124)

# tab bar animation (0 = story, 1 = settings)
var tab_pos: float = 0.0

# leaderboard
var lb_names: Array = ["Luna", "Max", "Aria", "Zayn", "Mia", "Leo", "Nora", "Kabir", "Ivy", "Rohan",
	"Sofia", "Arjun", "Chloe", "Dev", "Emma", "Anaya", "Noah", "Riya"]
var lb_levels: Array = [200, 192, 182, 174, 166, 156, 144, 132, 122, 110, 98, 86, 72, 56, 40, 26, 16, 8]
var lb_entries: Array = []

# settings screen rows: id, label, kind, icon color
var settings_items: Array = [
	["sound", "Sound Effects", "toggle", Color(0.98, 0.58, 0.16)],
	["music", "Music", "toggle", Color(0.62, 0.40, 0.90)],
	["privacy", "Privacy Policy", "link", Color(0.20, 0.52, 0.96)],
	["terms", "Terms & Conditions", "link", Color(0.25, 0.80, 0.40)],
	["about", "About Pour Pop", "link", Color(0.20, 0.85, 0.88)],
	#["rate", "Rate Us", "link", Color(0.98, 0.70, 0.15)],
	["contact", "Contact Support", "link", Color(0.98, 0.40, 0.70)],
]
var doc_kind: String = ""
var doc_lines: Array = []

# map camera and touch dragging
var cam_y: float = 0.0
var cam_vel: float = 0.0
var cam_follow: bool = false
var press_pos := Vector2.ZERO
var press_active: bool = false
var dragged: bool = false
var drag_vel: float = 0.0

# the man who jumps from level to level
var hop_state: String = "none"   # "none", "wait", "hop", "land"
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

# liquid geometry
var bottle_poly: PackedVector2Array
var unit_vol: float = 1.0
var band_cache: Dictionary = {}
var cap_cache: Dictionary = {}
var shade_polys: Array = []

# sand grains and gas puffs (points inside the bottle)
var grain_pts: Array = []
var puff_pts: Array = []
var fx_cache: Dictionary = {}

# animation state
var animating: bool = false
var anim_time: float = 0.0
var anim_total: float = 0.0
var anim_from: int = -1
var anim_to: int = -1
var anim_count: int = 0
var anim_color: int = 0
var anim_record: bool = true
var anim_dir: int = 1
var anim_home: Vector2 = Vector2.ZERO
var anim_v0: float = 0.0
var anim_pour_vol: float = 0.0
var anim_theta0: float = 0.0
var anim_theta_end: float = 0.0
var anim_t_pour: float = 1.0

# visual effects
var time_acc: float = 0.0
var fade: float = 0.0
var bubbles: Array = []
var stars: Array = []
var confetti: Array = []
var complete_fx: Dictionary = {}
var btn_styles: Dictionary = {}
var gloss_style: StyleBoxFlat
var tab_style: StyleBoxFlat
var card_style: StyleBoxFlat
var row_styles: Dictionary = {}
var toggle_on_style: StyleBoxFlat
var toggle_off_style: StyleBoxFlat

# sound
var sfx: Dictionary = {}
var pour_streams: Dictionary = {}
var water: AudioStreamPlayer
var music: AudioStreamPlayer
var music_thread: Thread


func _ready():
	update_layout()
	get_viewport().size_changed.connect(update_layout)
	DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT)
	bottle_poly = build_bottle_poly()
	unit_vol = polys_area(band_clip(Vector2(0, -1), -3000.0, -(NECK_H + SHOULDER_H))) / float(CAPACITY)
	build_band_cache()
	build_grains()
	build_shading()
	make_styles()
	init_background()
	init_garden()
	setup_sounds()
	setup_music()
	load_progress()
	screen = "play"
	start_level(clampi(unlocked, 1, TOTAL_LEVELS))

func _exit_tree():
	if music_thread != null and music_thread.is_started():
		music_thread.wait_to_finish()

# ---------------------------------------------------------------- progress

func update_layout():
	SCREEN_H = maxf(BASE_H, get_viewport_rect().size.y)
	extra_h = SCREEN_H - BASE_H
	var win: Vector2i = DisplayServer.window_get_size()
	var safe: Rect2i = DisplayServer.get_display_safe_area()
	var k: float = SCREEN_W / maxf(1.0, float(win.x))
	var s_top: float = 0.0
	var s_bot: float = 0.0
	if safe.size.y > 0:
		s_top = float(safe.position.y) * k
		s_bot = float(win.y - safe.position.y - safe.size.y) * k
	top_pad = maxf(0.0, s_top - 30.0)
	var dy: float = extra_h - maxf(0.0, s_bot - 28.0)
	menu_rect = Rect2(30, 40 + top_pad, 90, 90)
	undo_rect = Rect2(150, 1100 + dy, 170, 110)
	restart_rect = Rect2(400, 1100 + dy, 170, 110)
	tab_rect = Rect2(180, 1128 + dy, 360, 124)
	
func load_progress():
	var cf := ConfigFile.new()
	if cf.load("user://progress.cfg") == OK:
		unlocked = int(cf.get_value("game", "unlocked", 1))
		completed = int(cf.get_value("game", "completed", 0))
		sound_on = bool(cf.get_value("settings", "sound", true))
		music_on = bool(cf.get_value("settings", "music", true))
		house_done = int(cf.get_value("house", "done", 0))
		var hc: Array = cf.get_value("house", "choices", [])
		house_choice = []
		for hv in hc:
			house_choice.append(int(hv))
	unlocked = clampi(unlocked, 1, TOTAL_LEVELS)
	completed = clampi(completed, 0, TOTAL_LEVELS)
	house_done = clampi(mini(house_done, house_choice.size()), 0, HOUSE_STEPS.size())
	house_choice.resize(house_done)
	rebuild_house()

func save_progress():
	var cf := ConfigFile.new()
	cf.set_value("game", "unlocked", unlocked)
	cf.set_value("game", "completed", completed)
	cf.set_value("settings", "sound", sound_on)
	cf.set_value("settings", "music", music_on)
	cf.set_value("house", "done", house_done)
	cf.set_value("house", "choices", house_choice)
	cf.save("user://progress.cfg")

# ---------------------------------------------------------------- sound

func synth(notes: Array, dur: float, vol: float, sweep: float = 1.0, square: bool = false) -> AudioStreamWAV:
	var rate: int = 22050
	var per: int = int(rate * dur)
	var total: int = per * notes.size()
	var bytes := PackedByteArray()
	bytes.resize(total * 2)
	var phase: float = 0.0
	for n in notes.size():
		for i in per:
			var t: float = float(i) / float(per)
			var f: float = notes[n] * lerpf(1.0, sweep, t)
			phase += TAU * f / float(rate)
			var s: float = sin(phase)
			if square:
				s = 0.5 if s >= 0.0 else -0.5
			var attack: float = minf(1.0, float(i) / (rate * 0.005))
			var env: float = attack * pow(1.0 - t, 2.0)
			var v: int = int(clampf(s * env * vol, -1.0, 1.0) * 32767.0)
			bytes.encode_s16((n * per + i) * 2, v)
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = rate
	w.stereo = false
	w.data = bytes
	return w

# Soft, gentle pouring loops (replaces the old harsh water noise).
#  liquid: low, smooth "pouring" rumble with a few very soft bubbles
#  sand:   quiet "shhh" with tiny grain crackles
#  gas:    airy, slowly breathing hiss
func make_pour_loop(kind: String) -> AudioStreamWAV:
	var rate: int = 22050
	var n: int = rate
	var x: int = 2000
	var a1: float = 0.06
	var a2: float = 0.012
	var target: float = 0.30
	match kind:
		"sand":
			a1 = 0.40
			a2 = 0.12
			target = 0.20
		"gas":
			a1 = 0.12
			a2 = 0.02
			target = 0.22
	var raw := PackedFloat32Array()
	raw.resize(n + x)
	var lp1: float = 0.0
	var lp2: float = 0.0
	var peak: float = 0.0001
	for i in n + x:
		var white: float = randf() * 2.0 - 1.0
		lp1 += (white - lp1) * a1
		lp2 += (white - lp2) * a2
		var s: float = lp1 - lp2
		var tt: float = float(i) / float(rate)
		var mod: float = 0.85 + 0.15 * sin(TAU * 2.0 * tt)
		if kind == "gas":
			mod = 0.7 + 0.3 * sin(TAU * 1.0 * tt)
		s *= mod
		raw[i] = s
		peak = maxf(peak, absf(s))
	var k_gain: float = target / peak
	for i in n + x:
		raw[i] *= k_gain
	if kind == "sand":
		for i in n + x:
			if randf() < 0.012:
				raw[i] += (randf() * 2.0 - 1.0) * 0.12
	if kind == "liquid":
		var pos: int = 0
		while pos < n + x - 2000:
			var bl: int = randi_range(900, 1800)
			var f0: float = randf_range(180.0, 320.0)
			var ph: float = 0.0
			for k in bl:
				var u: float = float(k) / float(bl)
				ph += TAU * f0 * (1.0 + 0.5 * u) / float(rate)
				var env: float = sin(PI * u)
				env = env * env
				raw[pos + k] += sin(ph) * env * 0.08
			pos += randi_range(3500, 8000)
	var bytes := PackedByteArray()
	bytes.resize(n * 2)
	for i in n:
		var s2: float = raw[i]
		if i < x:
			var m: float = float(i) / float(x)
			s2 = raw[i] * m + raw[n + i] * (1.0 - m)
		var v: int = int(clampf(s2, -1.0, 1.0) * 0.6 * 32767.0)
		bytes.encode_s16(i * 2, v)
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = rate
	w.stereo = false
	w.data = bytes
	w.loop_mode = AudioStreamWAV.LOOP_FORWARD
	w.loop_begin = 0
	w.loop_end = n
	return w

# Soft ambient music loop, built on a background thread.
func make_music_loop() -> AudioStreamWAV:
	var rate: int = 11025
	var n: int = rate * 16
	var buf := PackedFloat32Array()
	buf.resize(n)

	var chords: Array = [
		[261.63, 329.63, 392.00, 493.88],
		[220.00, 261.63, 329.63, 392.00],
		[174.61, 261.63, 329.63, 440.00],
		[196.00, 293.66, 392.00, 493.88],
	]
	for ci in chords.size():
		var notes: Array = chords[ci]
		var start: float = float(ci) * 4.0 - 1.0
		var start_idx: int = int(start * float(rate))
		var count: int = rate * 6
		for i in count:
			var tt: float = float(i) / float(rate)
			var env: float = 0.5 * (1.0 - cos(TAU * tt / 6.0))
			var at: float = start + tt
			var s: float = 0.0
			for f in notes:
				var fr: float = f
				var ph: float = TAU * fr * at
				s += sin(ph) + 0.35 * sin(2.0 * ph * 1.002)
			buf[posmod(start_idx + i, n)] += s * env * 0.045

	var mel: Array = [659.25, 783.99, 880.0, 783.99, 1046.5, 880.0, 783.99, 659.25]
	for k in mel.size():
		var f0: float = mel[k]
		var st_idx: int = k * 2 * rate
		var cnt: int = rate * 3
		for i in cnt:
			var tt2: float = float(i) / float(rate)
			var env2: float = minf(1.0, tt2 / 0.01) * exp(-tt2 * 1.8)
			var s2: float = (sin(TAU * f0 * tt2) + 0.3 * sin(TAU * f0 * 2.01 * tt2)) * env2 * 0.12
			buf[(st_idx + i) % n] += s2

	var peak: float = 0.001
	for i in n:
		peak = maxf(peak, absf(buf[i]))
	var gain: float = 0.7 / peak
	var bytes := PackedByteArray()
	bytes.resize(n * 2)
	for i in n:
		bytes.encode_s16(i * 2, int(clampf(buf[i] * gain, -1.0, 1.0) * 32767.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = rate
	w.stereo = false
	w.data = bytes
	w.loop_mode = AudioStreamWAV.LOOP_FORWARD
	w.loop_begin = 0
	w.loop_end = n
	return w

func add_sfx(sfx_name: String, stream: AudioStreamWAV):
	var p := AudioStreamPlayer.new()
	p.stream = stream
	add_child(p)
	sfx[sfx_name] = p

func setup_sounds():
	add_sfx("click", synth([900], 0.04, 0.5))
	add_sfx("select", synth([700], 0.07, 0.6, 1.4))
	add_sfx("invalid", synth([150, 130], 0.1, 0.4, 1.0, true))
	add_sfx("complete", synth([659, 880, 1175], 0.12, 0.6))
	add_sfx("win", synth([523, 659, 784, 1047, 784, 1047], 0.18, 0.7))
	add_sfx("blip", synth([700], 0.03, 0.25))
	add_sfx("jump", synth([320], 0.28, 0.5, 2.4))
	add_sfx("land", synth([230], 0.14, 0.7, 0.5))
	pour_streams["liquid"] = make_pour_loop("liquid")
	pour_streams["sand"] = make_pour_loop("sand")
	pour_streams["gas"] = make_pour_loop("gas")
	water = AudioStreamPlayer.new()
	water.stream = pour_streams["liquid"]
	add_child(water)

func setup_music():
	music = AudioStreamPlayer.new()
	music.volume_db = -9.0
	add_child(music)
	music_thread = Thread.new()
	music_thread.start(make_music_loop)

func play_sfx(sfx_name: String):
	if not sound_on:
		return
	var p: AudioStreamPlayer = sfx[sfx_name]
	p.play()

func update_water():
	var t: float = anim_time
	var in_pour: bool = t >= T_IN and t < T_IN + anim_t_pour
	if in_pour and sound_on:
		var p: float = (t - T_IN) / anim_t_pour
		var env: float = smooth(clampf(p / 0.15, 0.0, 1.0)) \
				* smooth(clampf((1.0 - p) / 0.25, 0.0, 1.0))
		water.volume_db = linear_to_db(maxf(env, 0.001)) - 4.0
		if not water.playing:
			water.play()
	elif water.playing:
		water.stop()

# ---------------------------------------------------------------- text helpers

func wrap_text(text: String, width: float, size: int) -> Array:
	var font: Font = ThemeDB.fallback_font
	var lines: Array = []
	var cur: String = ""
	var words: PackedStringArray = text.split(" ")
	for w in words:
		var test: String = w if cur == "" else cur + " " + w
		var tw: float = font.get_string_size(test, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
		if tw > width and cur != "":
			lines.append(cur)
			cur = w
		else:
			cur = test
	if cur != "":
		lines.append(cur)
	return lines

# like wrap_text, but keeps the line breaks ("\n") of the text
func wrap_paragraphs(text: String, width: float, size: int) -> Array:
	var lines: Array = []
	for para in text.split("\n"):
		if para == "":
			lines.append("")
		else:
			lines.append_array(wrap_text(para, width, size))
	return lines

# ---------------------------------------------------------------- per-frame update

func _process(delta):
	time_acc += delta

	if boss_intro_t > 0.0:
		boss_intro_t -= delta

	# start the background music as soon as it has finished building
	if music_thread != null and not music_thread.is_alive():
		var ms: AudioStream = music_thread.wait_to_finish()
		music_thread = null
		music.stream = ms
		music.play()

	# mute the music in settings
	var want_db: float = -9.0
	if not music_on:
		want_db = -80.0
	music.volume_db = lerpf(music.volume_db, want_db, minf(1.0, delta * 4.0))

	# tab bar bubble glides to the active tab
	tab_pos = lerpf(tab_pos, float(tab_index()), minf(1.0, delta * 10.0))

	for item in bubbles:
		var b: Dictionary = item
		b["y"] = float(b["y"]) - float(b["s"]) * delta
		if float(b["y"]) < -50.0:
			b["y"] = SCREEN_H + 50.0
			b["x"] = randf() * SCREEN_W

	if fade > 0.0:
		fade = maxf(0.0, fade - delta * 2.5)

	for item in confetti:
		var c: Dictionary = item
		c["y"] = float(c["y"]) + float(c["vy"]) * delta
		c["x"] = float(c["x"]) + sin(time_acc * 3.0 + float(c["rot"])) * 40.0 * delta
		c["rot"] = float(c["rot"]) + float(c["vr"]) * delta
	if not confetti.is_empty():
		confetti = confetti.filter(func(p): return float(p["y"]) < SCREEN_H + 40.0)

	if animating:
		update_water()

	if screen == "menu":
		update_map(delta)

	if toast_t > 0.0:
		toast_t -= delta

	if won and screen == "play":
		win_timer += delta
		reveal_t += delta
		if win_timer >= win_wait:
			win_timer = 0.0
			finish_level_transition()

	queue_redraw()

# ---------------------------------------------------------------- boss levels

# every 10th level is a boss level
func is_boss(l: int) -> bool:
	return l % 10 == 0

# ---------------------------------------------------------------- ads

# after a win (and after the ad): go straight to the next level (the map only opens at launch or from the menu button)
func finish_level_transition():
	if current_level < TOTAL_LEVELS:
		start_level(current_level + 1)
	else:
		go_menu()

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

# ---------------------------------------------------------------- tab bar / navigation

# the tab bar is shown on the story map and settings (2 tabs: Story, Settings)
func tab_visible() -> bool:
	if screen == "settings":
		return true
	return screen == "menu" and hop_state == "none"


func tab_index() -> int:
	match screen:
		"settings", "doc":
			return 1
	return 0


func tab_hit_rect(i: int) -> Rect2:
	var w: float = tab_rect.size.x / 2.0
	return Rect2(
		tab_rect.position.x + float(i) * w,
		tab_rect.position.y - 34.0,
		w,
		tab_rect.size.y + 34.0
	)


func lb_unlocked() -> bool:
	return completed >= LB_UNLOCK_LEVEL

func show_toast(text: String):
	toast_text = text
	toast_t = 2.8

func set_tab(i: int):
	play_sfx("click")
	match i:
		0:
			if screen != "menu":
				go_menu()
		1:
			open_settings()

func build_board():
	lb_entries.clear()
	var me_added: bool = false
	for i in lb_names.size():
		if not me_added and completed > int(lb_levels[i]):
			lb_entries.append(["You", completed, true])
			me_added = true
		lb_entries.append([lb_names[i], lb_levels[i], false])
	if not me_added:
		lb_entries.append(["You", completed, true])

func open_leaderboard():
	screen = "leaderboard"
	selected = -1
	build_board()
	fade = 0.5

func open_settings():
	screen = "settings"
	selected = -1
	fade = 0.5

func open_doc(kind: String):
	doc_kind = kind
	var text: String = DOC_ABOUT
	match kind:
		"privacy":
			text = DOC_PRIVACY
		"terms":
			text = DOC_TERMS
		"about":
			text = DOC_ABOUT + "\n\nVersion " + APP_VERSION
	doc_lines = wrap_paragraphs(text, 570.0, 26)
	screen = "doc"
	fade = 0.4

func open_link(url: String):
	if url == "":
		play_sfx("invalid")
	else:
		play_sfx("click")
		OS.shell_open(url)

func contact_support() -> void:
	play_sfx("click")
	
	var os_name: String = OS.get_name()
	
	# On mobile devices, mailto: can fail or crash if no mail client is set up.
	# Copying to clipboard and showing a toast provides a reliable fallback.
	if os_name == "Android" or os_name == "iOS":
		DisplayServer.clipboard_set(SUPPORT_EMAIL)
		show_toast("Support email copied:\n" + SUPPORT_EMAIL)
	else:
		var mailto_url = "mailto:" + SUPPORT_EMAIL + "?subject=Pour%20Pop%20support"
		var error = OS.shell_open(mailto_url)
		if error != OK:
			# Fallback for desktop environments where mail client fails to open
			DisplayServer.clipboard_set(SUPPORT_EMAIL)
			show_toast("Could not open mail client. Email copied:\n" + SUPPORT_EMAIL)
		
func settings_rect(i: int) -> Rect2:
	var extra: float = 34.0 if i >= 2 else 0.0
	return Rect2(40.0, 205.0 + float(i) * 104.0 + extra + top_pad, 640.0, 90.0)

func activate_setting(i: int):
	var id: String = settings_items[i][0]
	match id:
		"sound":
			sound_on = not sound_on
			if not sound_on:
				if water.playing:
					water.stop()
			play_sfx("click")
			save_progress()
		"music":
			music_on = not music_on
			play_sfx("click")
			save_progress()
		"privacy":
			play_sfx("click")
			if PRIVACY_URL != "":
				OS.shell_open(PRIVACY_URL)
			else:
				open_doc("privacy")
		"terms":
			play_sfx("click")
			if TERMS_URL != "":
				OS.shell_open(TERMS_URL)
			else:
				open_doc("terms")
		"about":
			play_sfx("click")
			open_doc("about")
		"rate":
			open_link(RATE_URL)
		"contact":
			contact_support()

# ---------------------------------------------------------------- geometry helpers

func smooth(u: float) -> float:
	return u * u * (3.0 - 2.0 * u)

func build_bottle_poly() -> PackedVector2Array:
	var bx: float = TUBE_W / 2.0
	var nx: float = NECK_W / 2.0
	var y1: float = NECK_H
	var y2: float = NECK_H + SHOULDER_H
	var left: Array = []
	left.append(Vector2(-nx, 0.0))
	left.append(Vector2(-nx, y1))
	for k in range(1, SHOULDER_STEPS + 1):
		var u: float = float(k) / float(SHOULDER_STEPS)
		left.append(Vector2(-lerpf(nx, bx, smooth(u)), lerpf(y1, y2, u)))
	var ccx: float = -bx + BOTTLE_RADIUS
	var ccy: float = TUBE_H - BOTTLE_RADIUS
	for k in range(1, ARC_STEPS + 1):
		var a: float = lerpf(PI, PI / 2.0, float(k) / float(ARC_STEPS))
		left.append(Vector2(ccx + BOTTLE_RADIUS * cos(a), ccy + BOTTLE_RADIUS * sin(a)))
	var pts := PackedVector2Array()
	for p in left:
		var lp: Vector2 = p
		pts.append(lp)
	for i in range(left.size() - 1, -1, -1):
		var q: Vector2 = left[i]
		pts.append(Vector2(-q.x, q.y))
	return pts

func poly_area(p: PackedVector2Array) -> float:
	var a: float = 0.0
	var n: int = p.size()
	for i in n:
		var q: Vector2 = p[i]
		var r: Vector2 = p[(i + 1) % n]
		a += q.x * r.y - r.x * q.y
	return a * 0.5

func polys_area(polys: Array) -> float:
	var total: float = 0.0
	for item in polys:
		var p: PackedVector2Array = item
		total += absf(poly_area(p))
	return total

func band_clip(u: Vector2, h_lo: float, h_hi: float) -> Array:
	var w := Vector2(-u.y, u.x)
	var big: float = 1000.0
	var quad := PackedVector2Array([
		w * (-big) + u * h_lo,
		w * big + u * h_lo,
		w * big + u * h_hi,
		w * (-big) + u * h_hi,
	])
	return Geometry2D.intersect_polygons(bottle_poly, quad)

func h_range(u: Vector2) -> Vector2:
	var lo: float = INF
	var hi: float = -INF
	for p in bottle_poly:
		var d: float = p.dot(u)
		lo = minf(lo, d)
		hi = maxf(hi, d)
	return Vector2(lo, hi)

func level_for(u: Vector2, v: float) -> float:
	var r: Vector2 = h_range(u)
	var lo: float = r.x
	var hi: float = r.y
	for k in 12:
		var mid: float = (lo + hi) * 0.5
		if polys_area(band_clip(u, -3000.0, mid)) < v:
			lo = mid
		else:
			hi = mid
	return (lo + hi) * 0.5

func pour_angle(v: float) -> float:
	var lo: float = 0.0
	var hi: float = deg_to_rad(88.0)
	var lip := Vector2(NECK_W / 2.0, 0.0)
	for k in 12:
		var mid: float = (lo + hi) * 0.5
		var u: Vector2 = Vector2(0, -1).rotated(-mid)
		var cap: float = polys_area(band_clip(u, -3000.0, lip.dot(u)))
		if cap > v:
			lo = mid
		else:
			hi = mid
	return (lo + hi) * 0.5

func ellipse_pts(c: Vector2, rx: float, ry: float, steps: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for k in steps:
		var a: float = TAU * float(k) / float(steps)
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	return pts

func surface_cap(u: Vector2, h: float) -> Array:
	var w := Vector2(-u.y, u.x)
	var strip: Array = band_clip(u, h - 1.5, h + 1.5)
	var lo: float = INF
	var hi: float = -INF
	for item in strip:
		var p: PackedVector2Array = item
		for q in p:
			var d: float = q.dot(w)
			lo = minf(lo, d)
			hi = maxf(hi, d)
	if lo > hi:
		return []
	var center: Vector2 = u * h + w * ((lo + hi) * 0.5)
	var rx: float = (hi - lo) * 0.5
	var pts := PackedVector2Array()
	var steps: int = 20
	for k in steps:
		var a: float = TAU * float(k) / float(steps)
		pts.append(center + w * (cos(a) * rx) + u * (sin(a) * SURFACE_RY))
	return Geometry2D.intersect_polygons(bottle_poly, pts)

func build_band_cache():
	var u := Vector2(0, -1)
	var lv: Array = []
	lv.append(h_range(u).x - 2.0)
	for k in range(1, CAPACITY + 1):
		lv.append(level_for(u, k * unit_vol))
	for lo in range(0, CAPACITY):
		for hi in range(lo + 1, CAPACITY + 1):
			var h_lo: float = lv[lo]
			if lo > 0:
				h_lo -= 0.6
			var h_hi: float = lv[hi]
			band_cache[Vector2i(lo, hi)] = band_clip(u, h_lo, h_hi)
	cap_cache.clear()
	for k in range(1, CAPACITY + 1):
		var lvk: float = lv[k]
		cap_cache[k] = surface_cap(u, lvk)

func build_shading():
	var bx: float = TUBE_W / 2.0
	var defs: Array = [
		[-bx + 7.0, -bx + 19.0, Color(1, 1, 1, 0.28)],
		[-bx + 19.0, -bx + 30.0, Color(1, 1, 1, 0.09)],
		[bx - 26.0, bx - 12.0, Color(0, 0, 0, 0.14)],
		[bx - 12.0, bx + 2.0, Color(0, 0, 0, 0.24)],
	]
	shade_polys.clear()
	for item in defs:
		var d: Array = item
		var x0: float = d[0]
		var x1: float = d[1]
		var col: Color = d[2]
		var rect := PackedVector2Array([
			Vector2(x0, -50.0), Vector2(x1, -50.0),
			Vector2(x1, TUBE_H + 50.0), Vector2(x0, TUBE_H + 50.0)])
		shade_polys.append([Geometry2D.intersect_polygons(bottle_poly, rect), col])

# random points inside the bottle: sand grains and gas puffs
func build_grains():
	var rng := RandomNumberGenerator.new()
	rng.seed = 77
	grain_pts.clear()
	puff_pts.clear()
	var bx: float = TUBE_W / 2.0

	var in1: Array = Geometry2D.offset_polygon(bottle_poly, -6.0)
	if not in1.is_empty():
		var inner1: PackedVector2Array = in1[0]
		var tries: int = 0
		while grain_pts.size() < 240 and tries < 8000:
			tries += 1
			var p := Vector2(rng.randf_range(-bx, bx), rng.randf_range(0.0, TUBE_H))
			if Geometry2D.is_point_in_polygon(p, inner1):
				grain_pts.append([p, rng.randf_range(-1.0, 1.0), rng.randf() * TAU, rng.randf_range(1.2, 2.0)])

	var in2: Array = Geometry2D.offset_polygon(bottle_poly, -13.0)
	if not in2.is_empty():
		var inner2: PackedVector2Array = in2[0]
		var tries2: int = 0
		while puff_pts.size() < 34 and tries2 < 8000:
			tries2 += 1
			var q := Vector2(rng.randf_range(-bx, bx), rng.randf_range(0.0, TUBE_H))
			if Geometry2D.is_point_in_polygon(q, inner2):
				puff_pts.append([q, rng.randf_range(-1.0, 1.0), rng.randf() * TAU, rng.randf_range(7.0, 13.0)])

# keeps only the grains / puffs that lie inside the given polygons
func fx_for_polys(polys: Array) -> Array:
	var out: Array = []
	if fill_kind == "liquid":
		return out
	var pts: Array = grain_pts if fill_kind == "sand" else puff_pts
	for item in pts:
		var g: Array = item
		var p: Vector2 = g[0]
		for pl in polys:
			var poly: PackedVector2Array = pl
			if poly.size() >= 3 and Geometry2D.is_point_in_polygon(p, poly):
				out.append(g)
				break
	return out

func build_fx_cache():
	fx_cache.clear()
	if fill_kind == "liquid":
		return
	for key in band_cache.keys():
		var polys: Array = band_cache[key]
		fx_cache[key] = fx_for_polys(polys)

func make_bands(colors: Array, extra_color: int, extra_vol: float) -> Array:
	var bands: Array = []
	var v: float = 0.0
	for item in colors:
		var c: int = item
		var merged: bool = false
		if not bands.is_empty():
			var last: Array = bands.back()
			if int(last[0]) == c:
				last[2] = v + unit_vol
				merged = true
		if not merged:
			bands.append([c, v, v + unit_vol])
		v += unit_vol
	if extra_vol > 1.0:
		var added: bool = false
		if not bands.is_empty():
			var last2: Array = bands.back()
			if int(last2[0]) == extra_color:
				last2[2] = v + extra_vol
				added = true
		if not added:
			bands.append([extra_color, v, v + extra_vol])
	return bands

func liquid_polys(bands: Array, angle: float) -> Array:
	var u: Vector2 = Vector2(0, -1).rotated(-angle)
	var result: Array = []
	var h_lo: float = h_range(u).x - 2.0
	var prev_h: float = 0.0
	for idx in bands.size():
		var b: Array = bands[idx]
		var v_hi: float = b[2]
		var h_hi: float = level_for(u, v_hi)
		var bottom_cap: Array = []
		var top_cap: Array = []
		if idx > 0:
			bottom_cap = surface_cap(u, prev_h)
		if idx == bands.size() - 1:
			top_cap = surface_cap(u, h_hi)
		result.append([b[0], band_clip(u, h_lo, h_hi), bottom_cap, top_cap])
		prev_h = h_hi
		h_lo = h_hi - 0.6
	return result

# ---------------------------------------------------------------- levels

# some levels use sand, some use gas, the rest use liquid
func level_material(l: int) -> String:
	if l <= 4:
		return "liquid"
	match l % 6:
		3:
			return "sand"
		5:
			return "gas"
	return "liquid"

func level_config(l: int) -> Array:
	match l:
		1:
			return [2, 2]
		2:
			return [3, 2]
		3:
			return [3, 2]
		4:
			return [4, 2]
	# boss levels: more colors and fewer empty bottles
	if is_boss(l):
		return [clampi(5 + floori(float(l) / 10.0), 6, 10), 2 if l < 30 else 1]
	var colors: int = clampi(4 + floori(float(l - 5) / 10.0), 4, 10)
	var empty: int = 2
	if l >= 30 and l % 3 == 0:
		empty = 1
	return [colors, empty]

func start_level(l: int):
	current_level = l
	screen = "play"
	fade = 1.0
	hop_state = "none"
	boss_intro_t = BOSS_INTRO_TIME if is_boss(l) else 0.0
	fill_kind = level_material(l)
	build_fx_cache()
	var cfg: Array = level_config(l)
	generate_level(cfg[0], cfg[1], l)
	start_state.clear()
	for t in tubes:
		var arr: Array = t
		start_state.append(arr.duplicate())
	reset_play_state()

func reset_play_state():
	history.clear()
	complete_fx.clear()
	confetti.clear()
	selected = -1
	won = false
	win_timer = 0.0
	win_new_part = -1
	animating = false
	anim_from = -1
	anim_to = -1
	if water != null:
		water.stop()

func restart_level():
	tubes.clear()
	for t in start_state:
		var arr: Array = t
		tubes.append(arr.duplicate())
	reset_play_state()

func generate_level(num_colors: int, empty: int, level: int):
	while true:
		tubes.clear()
		for c in num_colors:
			var t: Array = []
			for k in CAPACITY:
				t.append(c)
			tubes.append(t)
		for e in empty:
			tubes.append([])
		var steps: int = mini(30 + level * 4, 300) + num_colors * 10
		for s in steps:
			var options: Array = []
			for a in tubes.size():
				var ta: Array = tubes[a]
				if ta.is_empty():
					continue
				var b: int = ta.back()
				if ta.size() > 1 and ta[ta.size() - 2] != b:
					continue
				for d in tubes.size():
					var td: Array = tubes[d]
					if d != a and td.size() < CAPACITY:
						options.append([a, d])
			if options.is_empty():
				break
			var mv: Array = options.pick_random()
			tubes[mv[1]].append(tubes[mv[0]].pop_back())
		if not check_win():
			break

# ---------------------------------------------------------------- layout

func tube_rect(i: int) -> Rect2:
	var n: int = tubes.size()
	var rows: int = 1 if n <= 6 else 2
	var per: int = ceili(float(n) / float(rows))
	var row: int = floori(float(i) / float(per))
	var col: int = i - row * per
	var cnt: int = mini(per, n - row * per)
	var total: float = cnt * TUBE_W + (cnt - 1) * GAP
	var start_x: float = (SCREEN_W - total) / 2.0
	var top_y: float = (380.0 if rows == 1 else 200.0 + row * 380.0) + extra_h * 0.5 + top_pad * 0.5
	return Rect2(start_x + col * (TUBE_W + GAP), top_y, TUBE_W, TUBE_H)

# ---------------------------------------------------------------- game rules

func top_group_size(t: int) -> int:
	var arr: Array = tubes[t]
	if arr.is_empty():
		return 0
	var c: int = arr.back()
	var n: int = 0
	var i: int = arr.size() - 1
	while i >= 0 and arr[i] == c:
		n += 1
		i -= 1
	return n

func is_complete(t: int) -> bool:
	var arr: Array = tubes[t]
	return arr.size() == CAPACITY and top_group_size(t) == CAPACITY

func can_move(from: int, to: int) -> bool:
	if from == to or tubes[from].is_empty():
		return false
	if tubes[to].size() >= CAPACITY:
		return false
	return tubes[to].is_empty() or tubes[to].back() == tubes[from].back()

func check_win() -> bool:
	for t in tubes:
		if t.is_empty():
			continue
		if t.size() != CAPACITY:
			return false
		for b in t:
			if b != t[0]:
				return false
	return true

# ---------------------------------------------------------------- input

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			press_pos = event.position
			press_active = true
			dragged = false
			cam_vel = 0.0
			drag_vel = 0.0
		elif press_active:
			press_active = false
			if dragged:
				if screen == "menu":
					cam_vel = clampf(drag_vel, -3500.0, 3500.0)
			else:
				handle_tap(event.position)
	elif event is InputEventMouseMotion and press_active and screen == "menu":
		if not dragged and event.position.distance_to(press_pos) > 14.0:
			dragged = true
			cam_follow = false
		if dragged and hop_state == "none":
			cam_y = clampf(cam_y - event.relative.y, 0.0, MAP_MAX_CAM)
			var dt: float = maxf(get_process_delta_time(), 0.004)
			drag_vel = lerpf(drag_vel, -event.relative.y / dt, 0.4)

func handle_tap(pos: Vector2):
	if animating:
		return

	# ---- bottom tab bar
	if tab_visible():
		for ti in 2:
			if tab_hit_rect(ti).has_point(pos):
				if ti != tab_index():
					set_tab(ti)
				return

	if screen == "leaderboard":
		return

	if screen == "house":
		house_tap(pos)
		return

	if screen == "settings":
		for si in settings_items.size():
			if settings_rect(si).has_point(pos):
				activate_setting(si)
				return
		return

	if screen == "doc":
		if menu_rect.has_point(pos):
			play_sfx("click")
			open_settings()
		return

	if screen == "menu":
		if hop_state != "none":
			return
		for idx in TOTAL_LEVELS:
			var p: Vector2 = track_pos(float(idx)) - Vector2(0.0, cam_y)
			if p.y < -80.0 or p.y > SCREEN_H + 80.0:
				continue
			if pos.distance_to(p) < 58.0:
				if idx < unlocked:
					play_sfx("click")
					start_level(idx + 1)
				else:
					play_sfx("invalid")
				return
		return

	# ---- play screen
	if menu_rect.has_point(pos):
		play_sfx("click")
		go_menu()
		return
	if restart_rect.has_point(pos):
		play_sfx("click")
		restart_level()
		return
	if won:
		return
	if undo_rect.has_point(pos):
		undo()
		return

	var idx2: int = -1
	for i in tubes.size():
		if tube_rect(i).has_point(pos):
			idx2 = i
	if idx2 == -1:
		if selected != -1:
			play_sfx("click")
		selected = -1
	elif selected == -1:
		if not tubes[idx2].is_empty():
			selected = idx2
			play_sfx("select")
	elif selected == idx2:
		selected = -1
		play_sfx("click")
	elif can_move(selected, idx2):
		var count: int = mini(top_group_size(selected), CAPACITY - tubes[idx2].size())
		start_move(selected, idx2, count, true)
	else:
		if tubes[idx2].is_empty():
			selected = -1
			play_sfx("invalid")
		else:
			selected = idx2
			play_sfx("select")

# ---------------------------------------------------------------- pouring

func start_move(from: int, to: int, count: int, record: bool):
	var lifted: bool = (from == selected)
	var r: Rect2 = tube_rect(from)
	var lift: float = LIFT if lifted else 0.0
	complete_fx.erase(from)
	complete_fx.erase(to)
	anim_home = Vector2(r.position.x + TUBE_W / 2.0, r.position.y - lift)
	anim_from = from
	anim_to = to
	anim_count = count
	anim_color = tubes[from].back()
	anim_record = record
	anim_dir = 1 if tube_rect(to).position.x > r.position.x else -1
	anim_v0 = tubes[from].size() * unit_vol
	anim_pour_vol = count * unit_vol
	anim_theta0 = pour_angle(anim_v0)
	anim_theta_end = pour_angle(anim_v0 - anim_pour_vol)
	anim_t_pour = 0.5 + 0.3 * count
	anim_total = T_IN + anim_t_pour + T_OUT
	anim_time = 0.0
	selected = -1
	animating = true
	# pick the pouring sound for liquid / sand / gas
	water.stop()
	water.stream = pour_streams[fill_kind]

	var tw: Tween = create_tween()
	tw.tween_property(self, "anim_time", anim_total, anim_total)
	tw.finished.connect(_on_anim_done)

func _on_anim_done():
	var src: Array = tubes[anim_from]
	var dst: Array = tubes[anim_to]
	for k in anim_count:
		dst.append(src.pop_back())
	if anim_record:
		history.append([anim_from, anim_to, anim_count])
	var finished_tube: int = anim_to
	animating = false
	anim_from = -1
	anim_to = -1
	water.stop()
	if check_win():
		do_win()
	elif anim_record and is_complete(finished_tube):
		play_sfx("complete")
		complete_fx[finished_tube] = time_acc

func do_win():
	if won:
		return
	won = true
	play_sfx("win")
	win_new_part = -1
	if current_level > completed:
		win_new_part = current_level - 1
	win_wait = WIN_DELAY
	reveal_t = 0.0
	completed = maxi(completed, current_level)
	if current_level < TOTAL_LEVELS and current_level + 1 > unlocked:
		unlocked = current_level + 1
	save_progress()
	win_timer = 0.0
	spawn_confetti()
	var k2: int = 0
	for i in tubes.size():
		if not tubes[i].is_empty():
			complete_fx[i] = time_acc + k2 * 0.12
			k2 += 1

func undo():
	if history.is_empty():
		play_sfx("invalid")
		return
	var m: Array = history.pop_back()
	start_move(m[1], m[0], m[2], false)

func pour_pivot(ang: float) -> Vector2:
	var tr: Rect2 = tube_rect(anim_to)
	var mouth := Vector2(tr.position.x + TUBE_W / 2.0, tr.position.y)
	var lip: Vector2 = Vector2(float(anim_dir) * NECK_W / 2.0, 0.0).rotated(ang)
	return mouth + Vector2(0.0, -POUR_H) - lip

func anim_state() -> Dictionary:
	var dir: float = float(anim_dir)
	var t: float = anim_time
	var pos: Vector2 = anim_home
	var ang: float = 0.0
	var poured: float = 0.0
	var prog: float = -1.0
	if t < T_IN:
		var k: float = smooth(t / T_IN)
		var a1: float = anim_theta0 * dir
		pos = anim_home.lerp(pour_pivot(a1), k)
		ang = lerpf(0.0, a1, k)
	elif t < T_IN + anim_t_pour:
		var p: float = (t - T_IN) / anim_t_pour
		poured = anim_pour_vol * p
		ang = pour_angle(anim_v0 - poured) * dir
		pos = pour_pivot(ang)
		prog = p
	else:
		var k2: float = smooth(clampf((t - T_IN - anim_t_pour) / T_OUT, 0.0, 1.0))
		var a2: float = anim_theta_end * dir
		poured = anim_pour_vol
		pos = pour_pivot(a2).lerp(anim_home, k2)
		ang = lerpf(a2, 0.0, k2)
	return {"pos": pos, "ang": ang, "poured": poured, "prog": prog}

# ---------------------------------------------------------------- setup of background and garden

func flat_style(bg: Color, border: Color, bw: int, radius: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(bw)
	s.set_corner_radius_all(radius)
	s.anti_aliasing = true
	return s

func make_styles():
	gloss_style = StyleBoxFlat.new()
	gloss_style.bg_color = Color(1, 1, 1, 0.22)
	gloss_style.corner_radius_top_left = 22
	gloss_style.corner_radius_top_right = 22
	gloss_style.corner_radius_bottom_left = 12
	gloss_style.corner_radius_bottom_right = 12
	gloss_style.anti_aliasing = true

	# floating tab bar (dark glass with a cool neon edge)
	tab_style = flat_style(Color(TAB_BAR_COL.r, TAB_BAR_COL.g, TAB_BAR_COL.b, 0.94),
		Color(0.35, 0.90, 1.0, 0.45), 2, 62)
	tab_style.shadow_color = Color(0, 0, 0, 0.55)
	tab_style.shadow_size = 18
	tab_style.shadow_offset = Vector2(0, 6)

	card_style = flat_style(Color(0.07, 0.04, 0.22, 0.88), Color(1, 1, 1, 0.22), 2, 30)

	# leaderboard / settings rows
	row_styles["normal"] = flat_style(Color(1, 1, 1, 0.10), Color(1, 1, 1, 0.16), 2, 26)
	row_styles["gold"] = flat_style(Color(1.0, 0.80, 0.25, 0.22), Color(1.0, 0.82, 0.3, 0.75), 3, 26)
	row_styles["silver"] = flat_style(Color(0.8, 0.86, 0.95, 0.18), Color(0.85, 0.9, 1.0, 0.6), 3, 26)
	row_styles["bronze"] = flat_style(Color(0.85, 0.52, 0.28, 0.20), Color(0.9, 0.6, 0.35, 0.65), 3, 26)
	row_styles["me"] = flat_style(Color(0.25, 0.85, 0.5, 0.25), Color(0.4, 1.0, 0.6, 0.9), 4, 26)

	toggle_on_style = flat_style(Color(0.2, 0.78, 0.42), Color(0.55, 1.0, 0.7), 3, 24)
	toggle_off_style = flat_style(Color(0.35, 0.35, 0.48), Color(0.6, 0.6, 0.72), 3, 24)

func init_background():
	for i in 26:
		bubbles.append({
			"x": randf() * SCREEN_W,
			"y": randf() * SCREEN_H,
			"r": randf_range(6.0, 26.0),
			"s": randf_range(14.0, 48.0),
			"a": randf_range(0.10, 0.28),
			"ph": randf() * TAU
		})
	for i in 50:
		stars.append({
			"x": randf() * SCREEN_W,
			"y": randf() * 900.0,
			"s": randf_range(1.2, 3.0),
			"ph": randf() * TAU
		})

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
	for k in 14:
		var py: float = 700.0 + k * 2100.0 + rng.randf_range(-300.0, 300.0)
		var tx: float = track_x_at_y(py)
		var px: float = 105.0 if tx > 360.0 else 615.0
		ponds.append({"x": px, "y": py, "rx": 80.0, "ry": 50.0})
	var tries: int = 0
	while trees.size() < 300 and tries < 6000:
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
	while bushes.size() < 180 and tries < 4000:
		tries += 1
		var bx: float = rng.randf_range(20.0, 700.0)
		var by: float = rng.randf_range(150.0, WORLD_H - 40.0)
		if not clear_of_track(bx, by, 95.0):
			continue
		bushes.append({"x": bx, "y": by, "s": rng.randf_range(0.7, 1.2)})
	tries = 0
	while flowers.size() < 1040 and tries < 8000:
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

func spawn_confetti():
	confetti.clear()
	for i in 90:
		confetti.append({
			"x": randf() * SCREEN_W,
			"y": randf_range(-500.0, -20.0),
			"vy": randf_range(220.0, 480.0),
			"rot": randf() * TAU,
			"vr": randf_range(-6.0, 6.0),
			"size": randf_range(12.0, 22.0),
			"col": COLORS[randi() % COLORS.size()]
		})

# ---------------------------------------------------------------- drawing helpers

func btn_style(col: Color) -> StyleBoxFlat:
	var key: String = col.to_html()
	if btn_styles.has(key):
		var cached: StyleBoxFlat = btn_styles[key]
		return cached
	var s := StyleBoxFlat.new()
	s.bg_color = col
	s.border_color = col.lightened(0.35)
	s.set_border_width_all(4)
	s.set_corner_radius_all(26)
	s.shadow_color = Color(0, 0, 0, 0.35)
	s.shadow_size = 8
	s.shadow_offset = Vector2(0, 6)
	s.anti_aliasing = true
	btn_styles[key] = s
	return s

func text_c(text: String, y: float, size: int, col: Color, x0: float = 0.0, w: float = SCREEN_W):
	var font: Font = ThemeDB.fallback_font
	draw_string(font, Vector2(x0 + 3.0, y + 4.0), text,
		HORIZONTAL_ALIGNMENT_CENTER, w, size, Color(0, 0, 0, 0.4))
	draw_string(font, Vector2(x0, y), text,
		HORIZONTAL_ALIGNMENT_CENTER, w, size, col)

# left-aligned text with a soft shadow
func text_l(text: String, pos: Vector2, size: int, col: Color):
	var font: Font = ThemeDB.fallback_font
	draw_string(font, pos + Vector2(2.0, 3.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color(0, 0, 0, 0.35))
	draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, col)

# right-aligned text: the text ends at x_right
func text_r(text: String, x_right: float, y: float, size: int, col: Color):
	var font: Font = ThemeDB.fallback_font
	draw_string(font, Vector2(x_right - 300.0 + 2.0, y + 3.0), text, HORIZONTAL_ALIGNMENT_RIGHT, 300.0, size, Color(0, 0, 0, 0.35))
	draw_string(font, Vector2(x_right - 300.0, y), text, HORIZONTAL_ALIGNMENT_RIGHT, 300.0, size, col)

func draw_button_base(rect: Rect2, color: Color):
	draw_style_box(btn_style(color), rect)
	draw_style_box(gloss_style, Rect2(rect.position.x + 6.0, rect.position.y + 5.0,
		rect.size.x - 12.0, rect.size.y * 0.4))

func draw_button(rect: Rect2, label: String, size: int, color: Color):
	draw_button_base(rect, color)
	var text_y: float = rect.position.y + rect.size.y / 2.0 + size * 0.35
	text_c(label, text_y, size, Color.WHITE, rect.position.x, rect.size.x)

func draw_icon_button(rect: Rect2, kind: String, color: Color):
	draw_button_base(rect, color)
	var c: Vector2 = rect.get_center()
	var s: float = minf(rect.size.x, rect.size.y) * 0.5
	match kind:
		"undo":
			draw_icon_undo(c, s, Color.WHITE)
		"restart":
			draw_icon_restart(c, s, Color.WHITE)
		"grid":
			draw_icon_grid(c, s, Color.WHITE)
		"back":
			draw_icon_back(c, s, Color.WHITE)

func draw_icon_undo(c: Vector2, s: float, col: Color):
	var r: float = s * 0.5
	var th: float = deg_to_rad(-150.0)
	draw_arc(c, r, th, deg_to_rad(80.0), 24, col, s * 0.16, true)
	var p: Vector2 = c + Vector2(cos(th), sin(th)) * r
	var tan_dir := Vector2(sin(th), -cos(th))
	var nrm := Vector2(cos(th), sin(th))
	draw_colored_polygon(PackedVector2Array([
		p + tan_dir * s * 0.34,
		p + nrm * s * 0.3,
		p - nrm * s * 0.3]), col)

func draw_icon_restart(c: Vector2, s: float, col: Color):
	var r: float = s * 0.5
	var th: float = deg_to_rad(230.0)
	draw_arc(c, r, deg_to_rad(-40.0), th, 28, col, s * 0.16, true)
	var p: Vector2 = c + Vector2(cos(th), sin(th)) * r
	var tan_dir := Vector2(-sin(th), cos(th))
	var nrm := Vector2(cos(th), sin(th))
	draw_colored_polygon(PackedVector2Array([
		p + tan_dir * s * 0.34,
		p + nrm * s * 0.3,
		p - nrm * s * 0.3]), col)

func draw_icon_grid(c: Vector2, s: float, col: Color):
	var cell: float = s * 0.36
	var gap: float = s * 0.12
	var total: float = cell * 2.0 + gap
	var origin: Vector2 = c - Vector2(total / 2.0, total / 2.0)
	for ix in 2:
		for iy in 2:
			draw_rect(Rect2(origin.x + ix * (cell + gap),
				origin.y + iy * (cell + gap), cell, cell), col)

func draw_icon_back(c: Vector2, s: float, col: Color):
	var tip: Vector2 = c + Vector2(-s * 0.42, 0.0)
	draw_line(tip, c + Vector2(s * 0.42, 0.0), col, s * 0.16, true)
	draw_polyline(PackedVector2Array([
		tip + Vector2(s * 0.32, -s * 0.34), tip, tip + Vector2(s * 0.32, s * 0.34)]),
		col, s * 0.16, true)

func draw_icon_lock(c: Vector2, s: float, col: Color):
	draw_arc(c + Vector2(0, -s * 0.12), s * 0.22, PI, TAU, 16, col, s * 0.1, true)
	draw_rect(Rect2(c.x - s * 0.32, c.y - s * 0.08, s * 0.64, s * 0.46), col)

func draw_check(c: Vector2, s: float):
	draw_circle(c, s, Color(0.1, 0.7, 0.35))
	draw_polyline(PackedVector2Array([
		c + Vector2(-s * 0.45, 0.0),
		c + Vector2(-s * 0.1, s * 0.38),
		c + Vector2(s * 0.5, -s * 0.35)]), Color.WHITE, s * 0.25, true)

func draw_sparkle(pos: Vector2, s: float, col: Color):
	var q: float = s * 0.25
	draw_colored_polygon(PackedVector2Array([
		pos + Vector2(0, -s), pos + Vector2(q, -q),
		pos + Vector2(s, 0), pos + Vector2(q, q),
		pos + Vector2(0, s), pos + Vector2(-q, q),
		pos + Vector2(-s, 0), pos + Vector2(-q, -q)]), col)

func draw_capsule(a: Vector2, b: Vector2, w: float, col: Color):
	draw_line(a, b, col, w, true)
	draw_circle(a, w / 2.0, col)
	draw_circle(b, w / 2.0, col)

func glow_blob(pos: Vector2, radius: float, col: Color):
	for k in 4:
		draw_circle(pos, radius * (1.0 - k * 0.2), Color(col.r, col.g, col.b, 0.035))

# night-sky background used on the play screen and the menu pages
func draw_background():
	var c0 := Color(0.09, 0.05, 0.27)
	var c1 := Color(0.33, 0.11, 0.52)
	var c2 := Color(0.04, 0.32, 0.55)
	var mid: float = SCREEN_H * 0.5
	draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(SCREEN_W, 0),
		Vector2(SCREEN_W, mid), Vector2(0, mid)]),
		PackedColorArray([c0, c0, c1, c1]))
	draw_polygon(PackedVector2Array([Vector2(0, mid), Vector2(SCREEN_W, mid),
		Vector2(SCREEN_W, SCREEN_H), Vector2(0, SCREEN_H)]),
		PackedColorArray([c1, c1, c2, c2]))

	glow_blob(Vector2(130.0 + 50.0 * sin(time_acc * 0.35), 260.0), 280.0, Color(1.0, 0.35, 0.8))
	glow_blob(Vector2(600.0 + 40.0 * cos(time_acc * 0.28), 700.0), 300.0, Color(0.2, 0.7, 1.0))
	glow_blob(Vector2(300.0 + 60.0 * sin(time_acc * 0.22 + 1.0), 1100.0), 320.0, Color(0.5, 0.3, 1.0))

	for item in stars:
		var sd: Dictionary = item
		var tw: float = 0.5 + 0.5 * sin(time_acc * 2.0 + float(sd["ph"]))
		draw_circle(Vector2(float(sd["x"]), float(sd["y"])),
			float(sd["s"]) * (0.6 + 0.6 * tw),
			Color(1, 1, 1, 0.25 + 0.55 * tw))

	for item in bubbles:
		var b: Dictionary = item
		var bx: float = float(b["x"]) + sin(time_acc * 0.8 + float(b["ph"])) * 14.0
		var bp := Vector2(bx, float(b["y"]))
		var a: float = float(b["a"])
		draw_circle(bp, float(b["r"]), Color(1, 1, 1, a * 0.35))
		draw_arc(bp, float(b["r"]), 0.0, TAU, 20, Color(1, 1, 1, a), 2.0, true)

func draw_shadow(r: Rect2):
	draw_set_transform(Vector2(r.position.x + TUBE_W / 2.0, r.end.y + 6.0), 0.0, Vector2(1.0, 0.22))
	draw_circle(Vector2.ZERO, TUBE_W * 0.62, Color(0, 0, 0, 0.28))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func draw_complete_fx(center: Vector2, col: Color, p: float):
	var fade_out: float = 1.0 - p
	draw_arc(center, 40.0 + p * 150.0, 0.0, TAU, 48,
		Color(col.r, col.g, col.b, 0.6 * fade_out), 6.0 * fade_out + 1.0, true)
	for k in 10:
		var a: float = float(k) / 10.0 * TAU + 0.4
		var dist: float = 60.0 + p * 130.0 * (0.7 + 0.3 * float(k % 3))
		var pos: Vector2 = center + Vector2(cos(a), sin(a)) * dist
		var sz: float = (10.0 + 8.0 * float(k % 3)) * (1.0 - p * 0.6)
		draw_sparkle(pos, sz, Color(1.0, 1.0, 0.8, fade_out))

func draw_confetti():
	for item in confetti:
		var c: Dictionary = item
		var s: float = float(c["size"])
		var col: Color = c["col"]
		draw_set_transform(Vector2(float(c["x"]), float(c["y"])), float(c["rot"]), Vector2.ONE)
		draw_rect(Rect2(-s / 2.0, -s / 3.0, s, s * 0.6), col)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

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
	# cam_y is large at level 1, so invert: near level 1 -> teal, near level 200 -> violet
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

# ---------------------------------------------------------------- bottle drawing

func fill_polys(polys: Array, col: Color):
	for item in polys:
		var p: PackedVector2Array = item
		if p.size() >= 3 and absf(poly_area(p)) > 1.0:
			draw_colored_polygon(p, col)

# little square grains that make the fill look like sand
func draw_grains(list: Array, col: Color):
	for item in list:
		var g: Array = item
		var p: Vector2 = g[0]
		var sh: float = g[1]
		var gc: Color = col.lightened(0.28 * sh) if sh > 0.0 else col.darkened(-0.35 * sh)
		var r: float = g[3]
		draw_rect(Rect2(p.x - r, p.y - r, r * 2.0, r * 2.0), gc)

# soft, slowly drifting puffs that make the fill look like gas
func draw_puffs(list: Array, col: Color):
	var puff: Color = col.lightened(0.55)
	puff.a = 0.22
	for item in list:
		var g: Array = item
		var p: Vector2 = g[0]
		var ph: float = g[2]
		var off := Vector2(sin(time_acc * 0.8 + ph) * 5.0, cos(time_acc * 0.6 + ph * 1.7) * 5.0)
		var r: float = float(g[3]) * (0.85 + 0.15 * sin(time_acc * 1.3 + ph))
		draw_circle(p + off, r, puff)

# fills one band of the bottle in the style of the current fill_kind
func fill_material(flat: Array, bcap: Array, tcap: Array, col: Color, fx: Array):
	match fill_kind:
		"sand":
			var sc: Color = col.darkened(0.06)
			fill_polys(flat, sc)
			fill_polys(bcap, sc)
			fill_polys(tcap, sc.lightened(0.18))
			draw_grains(fx, sc)
		"gas":
			fill_polys(flat, Color(col.r, col.g, col.b, 0.6))
			draw_puffs(fx, col)
		_:
			fill_polys(flat, col)
			fill_polys(bcap, col)
			fill_polys(tcap, col.lightened(0.3))

func draw_bottle(pivot: Vector2, angle: float, bands: Array, steady: bool, outline: Color, glow: Color = Color(0, 0, 0, 0)):
	draw_set_transform(pivot, angle, Vector2.ONE)
	if glow.a > 0.0:
		draw_polyline(bottle_poly, glow, TUBE_BORDER + 14.0, true)
	draw_colored_polygon(bottle_poly, Color(1, 1, 1, 0.08))

	if steady:
		for i in bands.size():
			var b: Array = bands[i]
			var lo: int = roundi(float(b[1]) / unit_vol)
			var hi: int = roundi(float(b[2]) / unit_vol)
			var col: Color = COLORS[b[0]]
			var key := Vector2i(lo, hi)
			var flat: Array = []
			if band_cache.has(key):
				flat = band_cache[key]
			var bcap: Array = []
			if lo > 0 and cap_cache.has(lo):
				bcap = cap_cache[lo]
			var tcap: Array = []
			if i == bands.size() - 1 and cap_cache.has(hi):
				tcap = cap_cache[hi]
			var fx: Array = []
			if fx_cache.has(key):
				fx = fx_cache[key]
			fill_material(flat, bcap, tcap, col, fx)
	else:
		for item in liquid_polys(bands, angle):
			var e: Array = item
			var col2: Color = COLORS[e[0]]
			var flat2: Array = e[1]
			var bcap2: Array = e[2]
			var tcap2: Array = e[3]
			fill_material(flat2, bcap2, tcap2, col2, fx_for_polys(flat2))

	for item in shade_polys:
		var sd: Array = item
		var sp: Array = sd[0]
		var scol: Color = sd[1]
		fill_polys(sp, scol)

	draw_polyline(bottle_poly, outline, TUBE_BORDER, true)

	var nx: float = NECK_W / 2.0
	var bx: float = TUBE_W / 2.0
	var rim: PackedVector2Array = ellipse_pts(Vector2.ZERO, nx + 2.0, MOUTH_RY, 24)
	draw_colored_polygon(rim, Color(0, 0, 0, 0.2))
	var rim_line := PackedVector2Array(rim)
	rim_line.append(rim[0])
	draw_polyline(rim_line, outline, 3.0, true)

	draw_line(Vector2(-bx + 15, NECK_H + SHOULDER_H + 24),
		Vector2(-bx + 15, TUBE_H - 44), Color(1, 1, 1, 0.3), 4.0, true)
	draw_circle(Vector2(-nx + 9, NECK_H - 12), 3.0, Color(1, 1, 1, 0.55))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func draw_stream(st: Dictionary):
	var prog: float = st["prog"]
	if prog < 0.0:
		return
	var poured: float = st["poured"]
	var tr: Rect2 = tube_rect(anim_to)
	var x: float = tr.position.x + TUBE_W / 2.0
	var y0: float = tr.position.y - POUR_H + 2.0
	var tv: float = tubes[anim_to].size() * unit_vol + poured
	var surf: float = tr.position.y - level_for(Vector2(0, -1), tv)
	var g: float = smooth(clampf(prog / 0.12, 0.0, 1.0))
	var s: float = smooth(clampf((prog - 0.88) / 0.12, 0.0, 1.0))
	var y_top: float = lerpf(y0, surf, s)
	var y_bot: float = lerpf(y0, surf, g)
	var col: Color = COLORS[anim_color]

	if fill_kind == "sand":
		var sc: Color = col.darkened(0.06)
		draw_line(Vector2(x, y_top), Vector2(x, y_bot), Color(sc.r, sc.g, sc.b, 0.55), 7.0, true)
		var span: float = y_bot - y_top
		for k in 24:
			var f: float = fposmod(anim_time * 2.6 + float(k) / 24.0, 1.0)
			var gx: float = x + sin(float(k) * 12.9898) * 5.0
			var gy: float = y_top + span * f
			var gc: Color = sc.lightened(0.2) if k % 2 == 0 else sc
			draw_rect(Rect2(gx - 1.6, gy - 1.6, 3.2, 3.2), gc)
		if g > 0.5 and s < 0.9:
			draw_colored_polygon(ellipse_pts(Vector2(x, surf), 16.0, 5.0, 14), sc.lightened(0.18))
	elif fill_kind == "gas":
		var pts := PackedVector2Array()
		var steps: int = 14
		for k in steps + 1:
			var yy: float = lerpf(y_top, y_bot, float(k) / float(steps))
			pts.append(Vector2(x + sin(anim_time * 6.0 + yy * 0.06) * 5.0, yy))
		if pts.size() >= 2 and y_bot - y_top > 2.0:
			draw_polyline(pts, Color(col.r, col.g, col.b, 0.45), 16.0, true)
			draw_polyline(pts, Color(1, 1, 1, 0.18), 6.0, true)
	else:
		var wob: float = 1.5 * sin(anim_time * 40.0)
		draw_line(Vector2(x, y_top), Vector2(x, y_bot), col, 12.0 + wob, true)
		draw_line(Vector2(x + 4, y_top), Vector2(x + 4, y_bot), col.darkened(0.3), 4.0, true)
		draw_line(Vector2(x - 2, y_top), Vector2(x - 2, y_bot), Color(1, 1, 1, 0.4), 3.0, true)
		if g > 0.5 and s < 0.9:
			draw_colored_polygon(ellipse_pts(Vector2(x, surf), 18.0 + wob, 6.0, 16), col.lightened(0.3))

# ---------------------------------------------------------------- screens

func _draw():
	match screen:
		"menu":
			draw_map()
		"play":
			if is_boss(current_level):
				draw_boss_background()
			else:
				draw_background()
			draw_play()
		"leaderboard":
			draw_background()
			draw_leaderboard()
		"settings":
			draw_background()
			draw_settings()
		"doc":
			draw_background()
			draw_doc()
		"house":
			draw_background()
			draw_house()
	if tab_visible():
		draw_tab_bar()
	draw_toast()
	if fade > 0.0:
		draw_rect(Rect2(0, 0, SCREEN_W, SCREEN_H), Color(0.05, 0.02, 0.15, fade))

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

func draw_play():
	text_c("LEVEL " + str(current_level), 100.0 + top_pad, 52, Color.WHITE)
	if fill_kind == "sand":
		text_c("SAND LEVEL", 150.0 + top_pad, 28, Color(1.0, 0.82, 0.45))
	elif fill_kind == "gas":
		text_c("GAS LEVEL", 150.0 + top_pad, 28, Color(0.55, 0.95, 1.0))

	var st: Dictionary = {}
	if animating:
		st = anim_state()

	for i in tubes.size():
		draw_shadow(tube_rect(i))

	var fx_list: Array = []

	for i in tubes.size():
		if animating and i == anim_from:
			continue
		var r: Rect2 = tube_rect(i)
		var lift: float = LIFT if i == selected else 0.0

		var hop: float = 0.0
		var fxp: float = -1.0
		if complete_fx.has(i):
			fxp = (time_acc - float(complete_fx[i])) / FX_TIME
			if fxp >= 0.0 and fxp < 1.0:
				hop = 24.0 * sin(minf(fxp / 0.5, 1.0) * PI)

		var pivot := Vector2(r.position.x + TUBE_W / 2.0, r.position.y - lift - hop)
		var is_target: bool = animating and i == anim_to
		var outline: Color = Color.WHITE
		var glow := Color(0, 0, 0, 0)
		if not is_target and is_complete(i):
			var cc: Color = COLORS[tubes[i][0]]
			outline = cc.lightened(0.5)
			glow = Color(cc.r, cc.g, cc.b, 0.35)
		if i == selected:
			outline = Color.GOLD

		if is_target:
			var bands_t: Array = make_bands(tubes[i], anim_color, float(st["poured"]))
			draw_bottle(pivot, 0.0, bands_t, false, outline, glow)
		else:
			var bands: Array = make_bands(tubes[i], 0, 0.0)
			draw_bottle(pivot, 0.0, bands, true, outline, glow)

		if fxp >= 0.0 and fxp < 1.0 and not is_target and not tubes[i].is_empty():
			fx_list.append([pivot + Vector2(0, TUBE_H * 0.55), COLORS[tubes[i][0]], fxp])

	if animating:
		draw_stream(st)
		var src: Array = tubes[anim_from]
		var colors: Array = src.slice(0, src.size() - anim_count)
		var poured2: float = st["poured"]
		var sb: Array = make_bands(colors, anim_color, anim_pour_vol - poured2)
		var pos: Vector2 = st["pos"]
		var ang: float = st["ang"]
		draw_bottle(pos, ang, sb, false, Color.WHITE)

	for item in fx_list:
		var e: Array = item
		draw_complete_fx(e[0], e[1], e[2])

	draw_icon_button(menu_rect, "grid", Color(0.35, 0.45, 0.95))
	draw_icon_button(undo_rect, "undo", Color(1.0, 0.55, 0.15))
	draw_icon_button(restart_rect, "restart", Color(0.15, 0.75, 0.45))

	# boss banner
	draw_boss_banner()

	if won:
		var msg: String = "LEVEL COMPLETE!"
		if current_level >= TOTAL_LEVELS:
			msg = "ALL 200 LEVELS DONE!"
		var wy: float = 260.0 + top_pad
		var bh: float = 130.0 if current_level < TOTAL_LEVELS else 90.0
		draw_rect(Rect2(0, wy - 70.0, SCREEN_W, bh), Color(0.05, 0.02, 0.15, 0.6))
		text_c(msg, wy, 64, Color(1.0, 0.9, 0.4))
		if current_level < TOTAL_LEVELS:
			text_c("Off to the next level...", wy + 50.0, 32, Color.WHITE)
		draw_confetti()

# ---------------------------------------------------------------- boss background and banner

# red / ember themed background for every 10th level
func draw_boss_background():
	var c0 := Color(0.16, 0.02, 0.08)
	var c1 := Color(0.45, 0.07, 0.15)
	var c2 := Color(0.28, 0.04, 0.20)
	var mid: float = SCREEN_H * 0.5
	draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(SCREEN_W, 0),
		Vector2(SCREEN_W, mid), Vector2(0, mid)]),
		PackedColorArray([c0, c0, c1, c1]))
	draw_polygon(PackedVector2Array([Vector2(0, mid), Vector2(SCREEN_W, mid),
		Vector2(SCREEN_W, SCREEN_H), Vector2(0, SCREEN_H)]),
		PackedColorArray([c1, c1, c2, c2]))

	var pulse: float = 0.5 + 0.5 * sin(time_acc * 1.5)
	glow_blob(Vector2(360.0, 260.0), 300.0 + 30.0 * pulse, Color(1.0, 0.25, 0.1))
	glow_blob(Vector2(110.0 + 40.0 * sin(time_acc * 0.4), 800.0), 280.0, Color(1.0, 0.45, 0.1))
	glow_blob(Vector2(620.0, 1050.0 + 30.0 * cos(time_acc * 0.3)), 300.0, Color(0.9, 0.1, 0.4))

	# rising embers (re-uses the bubble list for movement)
	for item in bubbles:
		var b: Dictionary = item
		var p := Vector2(float(b["x"]) + sin(time_acc * 1.2 + float(b["ph"])) * 18.0, float(b["y"]))
		var r: float = float(b["r"]) * 0.28
		draw_circle(p, r * 2.4, Color(1.0, 0.4, 0.1, 0.07))
		draw_circle(p, r, Color(1.0, 0.75, 0.3, 0.55))

func draw_boss_banner():
	if boss_intro_t > 0.0:
		var a: float = clampf(boss_intro_t / 0.5, 0.0, 1.0)
		draw_rect(Rect2(0, 560, SCREEN_W, 150), Color(0.1, 0.0, 0.03, 0.75 * a))
		text_c("BOSS LEVEL", 640.0, 70, Color(1.0, 0.4, 0.3, a))
		text_c("Good luck!", 688.0, 28, Color(1, 1, 1, a))

# ---------------------------------------------------------------- leaderboard

func draw_page_header(title: String, subtitle: String):
	draw_rect(Rect2(0, 0, SCREEN_W, 150 + top_pad), Color(0, 0, 0, 0.28))
	draw_rect(Rect2(0, 148 + top_pad, SCREEN_W, 3), Color(1, 1, 1, 0.12))
	text_c(title, 84.0 + top_pad, 56, Color(1.0, 0.9, 0.4))
	if subtitle != "":
		text_c(subtitle, 130.0 + top_pad, 26, Color(1, 1, 1, 0.85))

func draw_leaderboard():
	draw_page_header("LEADERBOARD", "Top sorters")

	var me_idx: int = -1
	for i in lb_entries.size():
		var en: Array = lb_entries[i]
		if bool(en[2]):
			me_idx = i
	var limit: int = 10
	var shown: Array = []
	for i in mini(limit, lb_entries.size()):
		shown.append(i)
	# if you are not in the top 10, your row replaces the last slot
	if me_idx >= limit:
		shown[limit - 1] = me_idx

	var medal_cols: Array = [Color(1.0, 0.82, 0.2), Color(0.80, 0.86, 0.94), Color(0.82, 0.52, 0.28)]

	for slot in shown.size():
		var ei: int = shown[slot]
		var e: Array = lb_entries[ei]
		var is_me: bool = bool(e[2])
		var r := Rect2(40.0, 178.0 + float(slot) * 88.0, 640.0, 76.0)
		var key: String = "normal"
		if is_me:
			key = "me"
		elif ei == 0:
			key = "gold"
		elif ei == 1:
			key = "silver"
		elif ei == 2:
			key = "bronze"
		draw_style_box(row_styles[key], r)
		var cy: float = r.position.y + r.size.y / 2.0

		# rank (medal for the top 3)
		if ei < 3:
			var mc: Color = medal_cols[ei]
			draw_circle(Vector2(88.0, cy), 27.0, mc.darkened(0.25))
			draw_circle(Vector2(88.0, cy), 23.0, mc)
			draw_circle(Vector2(80.0, cy - 8.0), 8.0, Color(1, 1, 1, 0.35))
			text_c(str(ei + 1), cy + 11.0, 30, Color(0.2, 0.12, 0.05), 58.0, 60.0)
		else:
			text_c("#" + str(ei + 1), cy + 10.0, 28, Color(1, 1, 1, 0.85), 50.0, 76.0)

		# avatar
		var av: Color = Color(0.3, 0.9, 0.5) if is_me else COLORS[ei % COLORS.size()]
		draw_circle(Vector2(172.0, cy), 28.0, Color(1, 1, 1, 0.85))
		draw_circle(Vector2(172.0, cy), 25.0, av)
		var nm: String = e[0]
		text_c(nm.substr(0, 1), cy + 10.0, 28, Color.WHITE, 142.0, 60.0)

		# name and score
		var name_col: Color = Color(0.7, 1.0, 0.8) if is_me else Color.WHITE
		text_l(nm, Vector2(220.0, cy - 2.0), 30, name_col)
		text_l("levels cleared", Vector2(220.0, cy + 24.0), 19, Color(1, 1, 1, 0.55))
		text_r(str(int(e[1])), 650.0, cy + 14.0, 40, Color(1.0, 0.9, 0.4))

# ---------------------------------------------------------------- settings

func draw_toggle(rect: Rect2, on: bool):
	draw_style_box(toggle_on_style if on else toggle_off_style, rect)
	var kx: float = rect.end.x - 25.0 if on else rect.position.x + 25.0
	var k := Vector2(kx, rect.position.y + rect.size.y / 2.0)
	draw_circle(k + Vector2(0, 2), 19.0, Color(0, 0, 0, 0.25))
	draw_circle(k, 19.0, Color.WHITE)

func draw_row_icon(id: String, c: Vector2):
	var col := Color.WHITE
	match id:
		"sound":
			draw_rect(Rect2(c.x - 15.0, c.y - 7.0, 9.0, 14.0), col)
			draw_colored_polygon(PackedVector2Array([
				Vector2(c.x - 7.0, c.y - 7.0), Vector2(c.x + 5.0, c.y - 16.0),
				Vector2(c.x + 5.0, c.y + 16.0), Vector2(c.x - 7.0, c.y + 7.0)]), col)
			if sound_on:
				draw_arc(c + Vector2(6.0, 0.0), 10.0, -0.9, 0.9, 8, col, 3.0, true)
			else:
				draw_line(c + Vector2(-15.0, -15.0), c + Vector2(15.0, 15.0), Color(1.0, 0.3, 0.3), 4.0, true)
		"music":
			draw_circle(c + Vector2(-6.0, 11.0), 7.0, col)
			draw_line(c + Vector2(0.0, 11.0), c + Vector2(0.0, -14.0), col, 4.0, true)
			draw_line(c + Vector2(0.0, -14.0), c + Vector2(13.0, -8.0), col, 4.0, true)
			if not music_on:
				draw_line(c + Vector2(-15.0, -15.0), c + Vector2(15.0, 15.0), Color(1.0, 0.3, 0.3), 4.0, true)
		"privacy":
			draw_icon_lock(c + Vector2(0.0, -2.0), 46.0, col)
		"terms":
			draw_rect(Rect2(c.x - 12.0, c.y - 16.0, 24.0, 32.0), col, false, 3.0)
			for k in 3:
				draw_line(Vector2(c.x - 6.0, c.y - 7.0 + k * 7.0), Vector2(c.x + 6.0, c.y - 7.0 + k * 7.0), col, 2.5)
		"about":
			text_c("i", c.y + 12.0, 34, col, c.x - 20.0, 40.0)
		"rate":
			var star := PackedVector2Array()
			for k in 10:
				var rr: float = 17.0 if k % 2 == 0 else 7.5
				var a: float = -PI / 2.0 + float(k) * PI / 5.0
				star.append(c + Vector2(cos(a), sin(a)) * rr + Vector2(0.0, 1.5))
			draw_colored_polygon(star, col)
		"contact":
			draw_rect(Rect2(c.x - 16.0, c.y - 11.0, 32.0, 22.0), col, false, 3.0)
			draw_polyline(PackedVector2Array([
				c + Vector2(-16.0, -11.0), c + Vector2(0.0, 3.0), c + Vector2(16.0, -11.0)]), col, 3.0, true)

func draw_settings():
	draw_page_header("Settings", "Make the game yours")
	for i in settings_items.size():
		var it: Array = settings_items[i]
		var id: String = it[0]
		var label: String = it[1]
		var kind: String = it[2]
		var icol: Color = it[3]
		var r: Rect2 = settings_rect(i)
		draw_style_box(row_styles["normal"], r)
		var c := Vector2(r.position.x + 56.0, r.position.y + r.size.y / 2.0)
		draw_circle(c + Vector2(0, 3), 31.0, Color(0, 0, 0, 0.25))
		draw_circle(c, 31.0, icol)
		draw_circle(c + Vector2(-9, -10), 11.0, Color(1, 1, 1, 0.22))
		draw_row_icon(id, c)
		text_l(label, Vector2(r.position.x + 108.0, c.y + 10.0), 30, Color.WHITE)
		if kind == "toggle":
			var on: bool = sound_on if id == "sound" else music_on
			draw_toggle(Rect2(r.end.x - 118.0, c.y - 24.0, 88.0, 48.0), on)
		else:
			var cx: float = r.end.x - 42.0
			draw_polyline(PackedVector2Array([
				Vector2(cx, c.y - 11.0), Vector2(cx + 11.0, c.y), Vector2(cx, c.y + 11.0)]),
				Color(1, 1, 1, 0.7), 4.0, true)
	var r2: Rect2 = settings_rect(2)
	text_l("INFO & LEGAL", Vector2(60.0, r2.position.y - 14.0), 22, Color(1, 1, 1, 0.6))
	text_c("Pour Pop  v" + APP_VERSION, 1070.0, 22, Color(1, 1, 1, 0.45))

func draw_doc():
	var titles: Dictionary = {"privacy": "PRIVACY POLICY", "terms": "TERMS & CONDITIONS", "about": "ABOUT"}
	var title: String = titles.get(doc_kind, "INFO")
	draw_page_header("", "")
	text_c(title, 100.0 + top_pad, 44, Color(1.0, 0.9, 0.4), 130.0, 560.0)
	draw_icon_button(menu_rect, "back", Color(0.35, 0.45, 0.95))
	draw_style_box(card_style, Rect2(40.0, 175.0 + top_pad, 640.0, 1010.0 + extra_h - top_pad))
	var font: Font = ThemeDB.fallback_font
	for li in doc_lines.size():
		var ln: String = doc_lines[li]
		draw_string(font, Vector2(75.0, 232.0 + top_pad + float(li) * 36.0), ln,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color(1, 1, 1, 0.92))

# ---------------------------------------------------------------- my house (no longer reachable from the tab bar)

const HOUSE_O = Vector2(40.0, 165.0)    # top-left corner of the house picture
const HOUSE_W = 640.0
const HOUSE_H = 600.0

const PAINT_COLS = [Color(0.62, 0.78, 0.92), Color(0.66, 0.86, 0.72), Color(0.97, 0.72, 0.64)]
const SOFA_COLS = [Color(0.80, 0.25, 0.28), Color(0.25, 0.45, 0.80), Color(0.55, 0.58, 0.62)]
const TV_COLS = [Color(0.45, 0.30, 0.18), Color(0.93, 0.93, 0.93), Color(0.12, 0.12, 0.14)]
const TV_SCREEN = [Color(0.25, 0.55, 0.85), Color(0.95, 0.55, 0.30), Color(0.30, 0.72, 0.50)]
const POT_COLS = [Color(0.78, 0.40, 0.25), Color(0.85, 0.85, 0.80), Color(0.25, 0.30, 0.45)]
const LAMP_COLS = [Color(0.98, 0.90, 0.70), Color(0.98, 0.70, 0.78), Color(0.65, 0.82, 0.98)]
const RUG_COLS = [Color(0.75, 0.25, 0.25), Color(0.20, 0.60, 0.62), Color(0.90, 0.70, 0.20)]
const CAB_COLS = [Color(0.94, 0.94, 0.92), Color(0.55, 0.72, 0.58), Color(0.72, 0.52, 0.32)]
const TABLE_COLS = [Color(0.76, 0.58, 0.38), Color(0.95, 0.95, 0.93), Color(0.28, 0.20, 0.16)]
const BED_COLS = [Color(0.30, 0.50, 0.85), Color(0.80, 0.28, 0.32), Color(0.30, 0.65, 0.42)]
const WARD_COLS = [Color(0.62, 0.44, 0.28), Color(0.94, 0.94, 0.92), Color(0.18, 0.24, 0.40)]
const TUB_COLS = [Color(0.96, 0.96, 0.97), Color(0.70, 0.86, 0.95), Color(0.16, 0.16, 0.19)]
const MIR_COLS = [Color(0.78, 0.80, 0.84), Color(0.92, 0.76, 0.30), Color(0.10, 0.10, 0.12)]
const CUR_COLS = [Color(0.80, 0.25, 0.30), Color(0.30, 0.50, 0.85), Color(0.30, 0.65, 0.42)]
const ROOF_COLS = [Color(0.72, 0.28, 0.22), Color(0.28, 0.40, 0.62), Color(0.45, 0.30, 0.20)]
const CHIM_COLS = [Color(0.62, 0.28, 0.20), Color(0.52, 0.52, 0.55), Color(0.92, 0.92, 0.90)]
const FENCE_COLS = [Color(0.97, 0.97, 0.95), Color(0.60, 0.42, 0.26), Color(0.13, 0.42, 0.20)]
const MAIL_COLS = [Color(0.85, 0.22, 0.22), Color(0.25, 0.45, 0.85), Color(0.25, 0.65, 0.38)]
const LIGHT_COLS = [Color(1.0, 0.88, 0.55), Color(0.70, 0.88, 1.0), Color(1.0, 0.70, 0.85)]
const BENCH_COLS = [Color(0.66, 0.46, 0.28), Color(0.28, 0.58, 0.36), Color(0.28, 0.46, 0.80)]
const FLOWER_COLS = [
	[Color(0.92, 0.20, 0.25), Color(1.0, 0.85, 0.20)],
	[Color(1.0, 0.55, 0.75), Color(1.0, 1.0, 1.0)],
	[Color(0.60, 0.35, 0.90), Color(0.35, 0.55, 1.0)],
]

# slots: 0 living room, 1 kitchen, 2 bedroom, 3 bathroom, 4 roof, 5 garden
# one step = one cleared level.  [slot, item, title]
# To make the house last all 200 levels just add more rows here.
const HOUSE_STEPS = [
	[0, "clean", "Clean the living room"],
	[0, "sofa", "Choose a sofa"],
	[1, "clean", "Clean the kitchen"],
	[1, "cabinet", "Choose the kitchen cabinets"],
	[5, "clean", "Mow the lawn"],
	[5, "tree", "Plant a tree"],
	[2, "clean", "Clean the bedroom"],
	[2, "bed", "Choose a bed"],
	[3, "clean", "Clean the bathroom"],
	[3, "tub", "Choose a bathtub"],
	[4, "clean", "Scrub the roof"],
	[4, "roof", "Choose the roof tiles"],
	[0, "paint", "Paint the living room"],
	[1, "paint", "Paint the kitchen"],
	[2, "paint", "Paint the bedroom"],
	[3, "paint", "Paint the bathroom"],
	[0, "floor", "Choose the living room floor"],
	[1, "floor", "Choose the kitchen floor"],
	[2, "floor", "Choose the bedroom floor"],
	[3, "floor", "Choose the bathroom floor"],
	[0, "tv", "Choose a TV"],
	[1, "table", "Choose a dining table"],
	[2, "wardrobe", "Choose a wardrobe"],
	[3, "sink", "Choose a sink and mirror"],
	[0, "curtain", "Hang living room curtains"],
	[2, "curtain", "Hang bedroom curtains"],
	[1, "curtain", "Hang kitchen curtains"],
	[3, "curtain", "Hang bathroom curtains"],
	[5, "fence", "Build a fence"],
	[5, "flowers", "Plant a flower bed"],
	[5, "mailbox", "Add a mailbox"],
	[4, "chimney", "Build a chimney"],
	[0, "art", "Hang a living room picture"],
	[1, "art", "Hang a kitchen picture"],
	[2, "art", "Hang a bedroom picture"],
	[3, "art", "Hang a bathroom picture"],
	[0, "plant", "Add a living room plant"],
	[2, "lamp", "Add a bedside lamp"],
	[5, "lights", "Add garden lights"],
	[0, "rug", "Choose a rug"],
	[3, "plant", "Add a bathroom plant"],
	[5, "bench", "Add a garden bench"],
]

const ITEM_LABELS = {
	"sofa": ["Ruby sofa", "Ocean sofa", "Stone sofa"],
	"tv": ["Walnut TV", "White TV", "Black TV"],
	"plant": ["Leafy bush", "Cactus", "Palm"],
	"rug": ["Red rug", "Teal rug", "Mustard rug"],
	"lamp": ["Warm lamp", "Rose lamp", "Sky lamp"],
	"cabinet": ["White kitchen", "Sage kitchen", "Oak kitchen"],
	"table": ["Oak table", "White table", "Dark table"],
	"bed": ["Blue bed", "Red bed", "Green bed"],
	"wardrobe": ["Wood wardrobe", "White wardrobe", "Navy wardrobe"],
	"tub": ["White tub", "Sky tub", "Black tub"],
	"sink": ["Silver mirror", "Gold mirror", "Black mirror"],
	"paint": ["Sky blue", "Fresh mint", "Peach"],
	"floor": ["Wood planks", "Tiles", "Carpet"],
	"curtain": ["Red curtains", "Blue curtains", "Green curtains"],
	"art": ["Landscape", "Sunset", "Abstract"],
	"roof": ["Red tiles", "Blue tiles", "Brown tiles"],
	"chimney": ["Brick", "Stone", "White"],
	"tree": ["Oak tree", "Pine tree", "Cherry tree"],
	"fence": ["White fence", "Wood fence", "Green hedge"],
	"flowers": ["Red flowers", "Pink flowers", "Violet flowers"],
	"mailbox": ["Red mailbox", "Blue mailbox", "Green mailbox"],
	"lights": ["Warm lights", "Cool lights", "Pink lights"],
	"bench": ["Wood bench", "Green bench", "Blue bench"],
}

# where each item stands. Rooms: x, y inside the room (floor at y = 126). Others: x, y in the picture.
# the third number is the scale
const ITEM_POS = {
	"0:sofa": [80.0, 126.0, 0.95], "0:tv": [160.0, 126.0, 0.8], "0:plant": [204.0, 126.0, 0.7],
	"0:rug": [105.0, 128.0, 1.1],
	"1:cabinet": [65.0, 126.0, 1.0], "1:table": [175.0, 126.0, 0.85],
	"2:bed": [62.0, 126.0, 0.95], "2:wardrobe": [190.0, 126.0, 0.9], "2:lamp": [140.0, 126.0, 0.8],
	"3:tub": [70.0, 126.0, 0.95], "3:sink": [166.0, 126.0, 0.9], "3:plant": [205.0, 126.0, 0.6],
	"4:chimney": [470.0, 112.0, 1.0],
	"5:tree": [605.0, 472.0, 0.75], "5:flowers": [250.0, 582.0, 0.9], "5:mailbox": [140.0, 568.0, 0.8],
	"5:bench": [385.0, 574.0, 0.85], "5:lights": [205.0, 582.0, 1.0],
}
const ART_POS = [[172.0, 38.0, 34.0, 28.0], [136.0, 40.0, 26.0, 22.0], [62.0, 36.0, 40.0, 30.0], [40.0, 40.0, 26.0, 22.0]]
const WIN_X = [100.0, 185.0, 148.0, 100.0]
const THUMB_S = {
	"sofa": 1.3, "tv": 1.5, "plant": 1.5, "rug": 1.4, "lamp": 1.3, "cabinet": 0.95, "table": 1.3,
	"bed": 1.3, "wardrobe": 1.0, "tub": 1.4, "sink": 1.0, "tree": 0.62, "fence": 1.1, "flowers": 1.4,
	"mailbox": 1.3, "lights": 1.2, "bench": 1.5, "chimney": 1.4,
}
const OUTDOOR_ITEMS = ["tree", "fence", "flowers", "mailbox", "lights", "bench", "chimney"]
const ROOM_ITEMS = ["rug", "sofa", "cabinet", "bed", "tub", "table", "tv", "wardrobe", "sink", "lamp", "plant"]

# ---- state

func house_pending() -> bool:
	return house_done < mini(completed, HOUSE_STEPS.size())

func open_house():
	screen = "house"
	selected = -1
	house_sel = -1
	fade = 0.5

func rebuild_house():
	house_items.clear()
	house_clean = [false, false, false, false, false, false]
	for i in house_done:
		var st: Array = HOUSE_STEPS[i]
		var slot: int = st[0]
		var item: String = st[1]
		if item == "clean":
			house_clean[slot] = true
		else:
			house_items[str(slot) + ":" + item] = int(house_choice[i])

# the chosen variant of an item (-1 = not there yet). The step that is open is shown as a preview.
func house_get(slot: int, item: String) -> int:
	var key: String = str(slot) + ":" + item
	if house_pending():
		var st: Array = HOUSE_STEPS[house_done]
		if house_sel >= 0 and int(st[0]) == slot and str(st[1]) == item:
			return house_sel
	return int(house_items.get(key, -1))

func do_house_step(choice: int):
	if not house_pending():
		return
	var st: Array = HOUSE_STEPS[house_done]
	var slot: int = st[0]
	var item: String = st[1]
	house_fx_slot = slot
	house_fx_clean = item == "clean"
	house_fx_pos = house_marker(slot, item)
	house_fx_t = time_acc
	house_choice.append(choice)
	house_done += 1
	house_sel = -1
	rebuild_house()
	play_sfx("complete")
	save_progress()

func house_card_rect(i: int) -> Rect2:
	return Rect2(50.0 + float(i) * 210.0, 896.0, 200.0, 146.0)

func house_tap(pos: Vector2):
	if not house_pending():
		return
	var st: Array = HOUSE_STEPS[house_done]
	var item: String = st[1]
	if item == "clean":
		if house_clean_rect.has_point(pos):
			do_house_step(0)
		return
	for i in 3:
		if house_card_rect(i).has_point(pos):
			house_sel = i
			play_sfx("select")
			return
	if house_sel >= 0 and house_place_rect.has_point(pos):
		do_house_step(house_sel)

func house_say() -> String:
	if house_pending():
		var st: Array = HOUSE_STEPS[house_done]
		var title: String = st[2]
		var lower: String = title.substr(0, 1).to_lower() + title.substr(1)
		if str(st[1]) == "clean":
			return "Great job on that level! Let's " + lower + ". Tap the button."
		return "Great job on that level! Let's " + lower + ". Tap one to preview it."
	if house_done >= HOUSE_STEPS.size():
		return "Our dream home is finished! Thank you so much!"
	return "All done for now! Clear another level and I'll have a new job for us."

func hash01(a: float) -> float:
	return fposmod(sin(a) * 43758.5453, 1.0)

# ---- placement helpers

func room_rect(slot: int) -> Rect2:
	var lx: float = 130.0
	var ly: float = 300.0
	if slot == 1:
		lx = 350.0
	elif slot == 2:
		ly = 160.0
	elif slot == 3:
		lx = 350.0
		ly = 160.0
	return Rect2(HOUSE_O + Vector2(lx, ly), Vector2(220.0, 140.0))

func slot_rect(slot: int) -> Rect2:
	if slot <= 3:
		return room_rect(slot)
	if slot == 4:
		return Rect2(HOUSE_O + Vector2(105.0, 46.0), Vector2(490.0, 120.0))
	return Rect2(HOUSE_O + Vector2(0.0, 440.0), Vector2(HOUSE_W, 160.0))

# returns [bottom-center position, scale]
func item_place(slot: int, item: String) -> Array:
	var d: Array = ITEM_POS.get(str(slot) + ":" + item, [110.0, 126.0, 1.0])
	var dx: float = d[0]
	var dy: float = d[1]
	var ds: float = d[2]
	if slot <= 3:
		return [room_rect(slot).position + Vector2(dx, dy), ds]
	return [HOUSE_O + Vector2(dx, dy), ds]

func house_marker(slot: int, item: String) -> Vector2:
	if item == "clean":
		return slot_rect(slot).get_center()
	if item == "roof":
		return HOUSE_O + Vector2(300.0, 100.0)
	if slot <= 3:
		var r: Rect2 = room_rect(slot)
		if item == "paint":
			return r.get_center()
		if item == "floor":
			return r.position + Vector2(110.0, 128.0)
		if item == "curtain":
			var wx: float = WIN_X[slot]
			return r.position + Vector2(wx, 44.0)
		if item == "art":
			var ap: Array = ART_POS[slot]
			var ax: float = ap[0]
			var ay: float = ap[1]
			return r.position + Vector2(ax, ay)
	var pl: Array = item_place(slot, item)
	var pc: Vector2 = pl[0]
	var ps: float = pl[1]
	return pc + Vector2(0.0, -34.0 * ps)

# ---- small drawing helpers

func rrect(r: Rect2, col: Color, rad: int = 8):
	var key: String = "rr" + col.to_html() + str(rad)
	if not btn_styles.has(key):
		btn_styles[key] = flat_style(col, col, 0, rad)
	var st: StyleBoxFlat = btn_styles[key]
	draw_style_box(st, r)

func ip(c: Vector2, s: float, x: float, y: float) -> Vector2:
	return c + Vector2(x, y) * s

func irect(c: Vector2, s: float, x: float, y: float, w: float, h: float) -> Rect2:
	return Rect2(c + Vector2(x, y) * s, Vector2(w, h) * s)

func ishadow(c: Vector2, s: float, w: float):
	draw_colored_polygon(ellipse_pts(c + Vector2(0.0, s), w * s, 4.0 * s, 14), Color(0, 0, 0, 0.22))

func draw_hill(x0: float, x1: float, base: float, amp: float, col: Color):
	var pts := PackedVector2Array()
	for k in 25:
		var u: float = float(k) / 24.0
		pts.append(Vector2(lerpf(x0, x1, u), base - amp * sin(PI * u)))
	pts.append(Vector2(x1, base + 20.0))
	pts.append(Vector2(x0, base + 20.0))
	draw_colored_polygon(pts, col)

# ---- items (c = bottom centre of the item, s = scale)

func item_sofa(v: int, c: Vector2, s: float):
	var col: Color = SOFA_COLS[v]
	ishadow(c, s, 58.0)
	rrect(irect(c, s, -52.0, -46.0, 104.0, 36.0), col.darkened(0.22), 10)
	rrect(irect(c, s, -34.0, -40.0, 30.0, 30.0), col.lightened(0.05), 8)
	rrect(irect(c, s, 4.0, -40.0, 30.0, 30.0), col.lightened(0.05), 8)
	rrect(irect(c, s, -58.0, -30.0, 18.0, 28.0), col, 8)
	rrect(irect(c, s, 40.0, -30.0, 18.0, 28.0), col, 8)
	rrect(irect(c, s, -40.0, -22.0, 80.0, 18.0), col.lightened(0.15), 7)
	draw_line(ip(c, s, 0.0, -22.0), ip(c, s, 0.0, -4.0), col.darkened(0.3), 1.5 * s, true)
	draw_rect(irect(c, s, -52.0, -3.0, 6.0, 4.0), Color(0.2, 0.12, 0.08))
	draw_rect(irect(c, s, 46.0, -3.0, 6.0, 4.0), Color(0.2, 0.12, 0.08))
	rrect(irect(c, s, -32.0, -38.0, 18.0, 16.0), col.lightened(0.5), 5)

func item_tv(v: int, c: Vector2, s: float):
	var wood: Color = TV_COLS[v]
	var sc: Color = TV_SCREEN[v]
	ishadow(c, s, 36.0)
	rrect(irect(c, s, -32.0, -22.0, 64.0, 22.0), wood, 4)
	draw_line(ip(c, s, 0.0, -21.0), ip(c, s, 0.0, -1.0), wood.darkened(0.35), 1.5 * s)
	draw_circle(ip(c, s, -6.0, -11.0), 1.8 * s, Color(0.9, 0.8, 0.5))
	draw_circle(ip(c, s, 6.0, -11.0), 1.8 * s, Color(0.9, 0.8, 0.5))
	rrect(irect(c, s, -30.0, -62.0, 60.0, 38.0), Color(0.06, 0.06, 0.08), 4)
	draw_rect(irect(c, s, -27.0, -59.0, 54.0, 32.0), sc)
	draw_rect(irect(c, s, -27.0, -45.0, 54.0, 18.0), sc.darkened(0.25))
	draw_colored_polygon(PackedVector2Array([ip(c, s, -27.0, -59.0), ip(c, s, -6.0, -59.0),
		ip(c, s, -20.0, -27.0), ip(c, s, -27.0, -27.0)]), Color(1, 1, 1, 0.12))

func item_plant(v: int, c: Vector2, s: float):
	var pot: Color = POT_COLS[v]
	ishadow(c, s, 20.0)
	if v == 0:
		var dots: Array = [Vector2(-10, -38), Vector2(10, -38), Vector2(0, -50), Vector2(-6, -30), Vector2(7, -30)]
		for k in dots.size():
			var dv: Vector2 = dots[k]
			var g: Color = Color(0.22, 0.62, 0.28).lightened(0.08 * float(k % 3))
			draw_circle(c + dv * s, 12.0 * s, g)
	elif v == 1:
		draw_line(ip(c, s, 0.0, -14.0), ip(c, s, 0.0, -48.0), Color(0.25, 0.60, 0.35), 15.0 * s, true)
		draw_circle(ip(c, s, 0.0, -48.0), 7.5 * s, Color(0.25, 0.60, 0.35))
		draw_polyline(PackedVector2Array([ip(c, s, -6.0, -30.0), ip(c, s, -17.0, -30.0), ip(c, s, -17.0, -41.0)]), Color(0.25, 0.60, 0.35), 7.0 * s, true)
		draw_polyline(PackedVector2Array([ip(c, s, 6.0, -26.0), ip(c, s, 17.0, -26.0), ip(c, s, 17.0, -36.0)]), Color(0.25, 0.60, 0.35), 7.0 * s, true)
		draw_circle(ip(c, s, 0.0, -56.0), 4.0 * s, Color(1.0, 0.5, 0.7))
	else:
		draw_line(ip(c, s, 0.0, -14.0), ip(c, s, 2.0, -44.0), Color(0.45, 0.30, 0.18), 5.0 * s, true)
		var tips: Array = [Vector2(-28, -32), Vector2(-20, -52), Vector2(2, -60), Vector2(24, -52), Vector2(30, -32)]
		for k in tips.size():
			var tv: Vector2 = tips[k]
			draw_line(ip(c, s, 2.0, -44.0), c + tv * s, Color(0.22, 0.60, 0.30), 6.0 * s, true)
	draw_colored_polygon(PackedVector2Array([ip(c, s, -12.0, -15.0), ip(c, s, 12.0, -15.0),
		ip(c, s, 9.0, 0.0), ip(c, s, -9.0, 0.0)]), pot)
	draw_rect(irect(c, s, -13.0, -18.0, 26.0, 5.0), pot.lightened(0.2))

func item_lamp(v: int, c: Vector2, s: float):
	var sh: Color = LAMP_COLS[v]
	ishadow(c, s, 12.0)
	for k in 3:
		draw_circle(ip(c, s, 0.0, -52.0), (28.0 - float(k) * 7.0) * s, Color(1.0, 0.9, 0.6, 0.07))
	draw_line(ip(c, s, 0.0, -4.0), ip(c, s, 0.0, -44.0), Color(0.30, 0.25, 0.20), 3.0 * s)
	draw_colored_polygon(ellipse_pts(ip(c, s, 0.0, -3.0), 10.0 * s, 3.0 * s, 10), Color(0.25, 0.20, 0.16))
	draw_colored_polygon(PackedVector2Array([ip(c, s, -14.0, -44.0), ip(c, s, 14.0, -44.0),
		ip(c, s, 9.0, -66.0), ip(c, s, -9.0, -66.0)]), sh)
	draw_circle(ip(c, s, 0.0, -44.0), 3.0 * s, Color(1.0, 0.95, 0.7))

func item_rug(v: int, c: Vector2, s: float):
	var col: Color = RUG_COLS[v]
	draw_colored_polygon(ellipse_pts(ip(c, s, 0.0, -4.0), 62.0 * s, 8.0 * s, 20), col.darkened(0.25))
	draw_colored_polygon(ellipse_pts(ip(c, s, 0.0, -4.0), 56.0 * s, 6.0 * s, 20), col)
	draw_colored_polygon(ellipse_pts(ip(c, s, 0.0, -4.0), 34.0 * s, 3.5 * s, 16), col.lightened(0.3))

func item_cabinet(v: int, c: Vector2, s: float):
	var col: Color = CAB_COLS[v]
	draw_rect(irect(c, s, -56.0, -104.0, 112.0, 58.0), Color(0.90, 0.92, 0.90, 0.55))
	for k in 6:
		draw_line(ip(c, s, -56.0 + float(k) * 22.0, -104.0), ip(c, s, -56.0 + float(k) * 22.0, -46.0), Color(0, 0, 0, 0.06), 1.0)
	rrect(irect(c, s, -54.0, -110.0, 50.0, 36.0), col, 3)
	rrect(irect(c, s, 4.0, -110.0, 50.0, 36.0), col, 3)
	draw_rect(irect(c, s, -10.0, -92.0, 3.0, 12.0), Color(0.75, 0.75, 0.78))
	draw_rect(irect(c, s, 7.0, -92.0, 3.0, 12.0), Color(0.75, 0.75, 0.78))
	rrect(irect(c, s, -56.0, -44.0, 112.0, 44.0), col, 3)
	draw_line(ip(c, s, 0.0, -44.0), ip(c, s, 0.0, 0.0), col.darkened(0.25), 1.5 * s)
	draw_rect(irect(c, s, -10.0, -34.0, 8.0, 3.0), Color(0.75, 0.75, 0.78))
	draw_rect(irect(c, s, 2.0, -34.0, 8.0, 3.0), Color(0.75, 0.75, 0.78))
	rrect(irect(c, s, -58.0, -48.0, 116.0, 6.0), Color(0.25, 0.25, 0.28), 2)
	rrect(irect(c, s, 14.0, -60.0, 24.0, 12.0), Color(0.72, 0.74, 0.78), 3)
	draw_line(ip(c, s, 14.0, -58.0), ip(c, s, 10.0, -56.0), Color(0.3, 0.3, 0.33), 2.0 * s)
	draw_line(ip(c, s, -36.0, -48.0), ip(c, s, -36.0, -60.0), Color(0.7, 0.72, 0.76), 3.0 * s)
	draw_line(ip(c, s, -36.0, -60.0), ip(c, s, -28.0, -60.0), Color(0.7, 0.72, 0.76), 3.0 * s)

func item_table(v: int, c: Vector2, s: float):
	var wood: Color = TABLE_COLS[v]
	ishadow(c, s, 50.0)
	for side in [-1.0, 1.0]:
		var sg: float = side
		var cx: float = sg * 36.0
		rrect(irect(c, s, cx - 6.0 - sg * 2.0, -42.0, 12.0, 24.0), wood.darkened(0.2), 3)
		draw_rect(irect(c, s, cx - 10.0, -20.0, 20.0, 4.0), wood.darkened(0.1))
		draw_line(ip(c, s, cx - 7.0, -16.0), ip(c, s, cx - 7.0, 0.0), wood.darkened(0.3), 2.0 * s)
		draw_line(ip(c, s, cx + 7.0, -16.0), ip(c, s, cx + 7.0, 0.0), wood.darkened(0.3), 2.0 * s)
	rrect(irect(c, s, -30.0, -38.0, 60.0, 6.0), wood, 2)
	draw_line(ip(c, s, -24.0, -32.0), ip(c, s, -24.0, 0.0), wood.darkened(0.3), 3.0 * s)
	draw_line(ip(c, s, 24.0, -32.0), ip(c, s, 24.0, 0.0), wood.darkened(0.3), 3.0 * s)
	draw_colored_polygon(ellipse_pts(ip(c, s, 0.0, -40.0), 9.0 * s, 3.0 * s, 10), Color(0.95, 0.95, 0.9))
	draw_circle(ip(c, s, -3.0, -44.0), 3.0 * s, Color(0.9, 0.2, 0.2))
	draw_circle(ip(c, s, 3.0, -44.0), 3.0 * s, Color(0.95, 0.8, 0.2))

func item_bed(v: int, c: Vector2, s: float):
	var bl: Color = BED_COLS[v]
	var wood := Color(0.48, 0.32, 0.20)
	ishadow(c, s, 64.0)
	rrect(irect(c, s, -58.0, -52.0, 10.0, 52.0), wood, 3)
	rrect(irect(c, s, -56.0, -20.0, 112.0, 18.0), wood, 3)
	rrect(irect(c, s, -50.0, -32.0, 100.0, 14.0), Color(0.95, 0.94, 0.90), 5)
	rrect(irect(c, s, -18.0, -36.0, 68.0, 20.0), bl, 6)
	draw_rect(irect(c, s, -18.0, -28.0, 68.0, 3.0), bl.lightened(0.3))
	rrect(irect(c, s, -46.0, -42.0, 26.0, 12.0), Color(1, 1, 1), 6)
	draw_rect(irect(c, s, 48.0, -2.0, 6.0, 3.0), wood.darkened(0.3))

func item_wardrobe(v: int, c: Vector2, s: float):
	var col: Color = WARD_COLS[v]
	ishadow(c, s, 28.0)
	rrect(irect(c, s, -24.0, -100.0, 48.0, 98.0), col, 3)
	rrect(irect(c, s, -26.0, -104.0, 52.0, 6.0), col.darkened(0.15), 2)
	draw_line(ip(c, s, 0.0, -98.0), ip(c, s, 0.0, -2.0), col.darkened(0.35), 1.5 * s)
	draw_rect(irect(c, s, -20.0, -90.0, 16.0, 40.0), Color(1, 1, 1, 0.10))
	draw_circle(ip(c, s, -4.0, -50.0), 2.0 * s, Color(0.92, 0.80, 0.45))
	draw_circle(ip(c, s, 4.0, -50.0), 2.0 * s, Color(0.92, 0.80, 0.45))
	draw_rect(irect(c, s, -22.0, -2.0, 6.0, 3.0), col.darkened(0.4))
	draw_rect(irect(c, s, 16.0, -2.0, 6.0, 3.0), col.darkened(0.4))

func item_tub(v: int, c: Vector2, s: float):
	var col: Color = TUB_COLS[v]
	ishadow(c, s, 58.0)
	rrect(irect(c, s, -54.0, -32.0, 108.0, 28.0), col, 12)
	rrect(irect(c, s, -56.0, -38.0, 112.0, 8.0), col.lightened(0.12), 4)
	draw_colored_polygon(ellipse_pts(ip(c, s, 0.0, -38.0), 50.0 * s, 4.0 * s, 16), Color(0.55, 0.82, 0.95))
	for k in 4:
		draw_circle(ip(c, s, -30.0 + float(k) * 16.0, -40.0 - float(k % 2) * 2.0), 4.0 * s, Color(1, 1, 1, 0.8))
	draw_circle(ip(c, s, 24.0, -42.0), 5.0 * s, Color(1.0, 0.85, 0.2))
	draw_circle(ip(c, s, 28.0, -44.0), 2.0 * s, Color(1.0, 0.5, 0.2))
	draw_circle(ip(c, s, -46.0, -2.0), 3.0 * s, Color(0.7, 0.7, 0.75))
	draw_circle(ip(c, s, 46.0, -2.0), 3.0 * s, Color(0.7, 0.7, 0.75))
	draw_polyline(PackedVector2Array([ip(c, s, -46.0, -38.0), ip(c, s, -46.0, -58.0), ip(c, s, -36.0, -58.0), ip(c, s, -36.0, -50.0)]), Color(0.75, 0.77, 0.82), 3.0 * s, true)

func item_sink(v: int, c: Vector2, s: float):
	var fr: Color = MIR_COLS[v]
	ishadow(c, s, 30.0)
	rrect(irect(c, s, -26.0, -38.0, 52.0, 38.0), Color(0.82, 0.72, 0.58), 3)
	draw_line(ip(c, s, 0.0, -36.0), ip(c, s, 0.0, -2.0), Color(0.5, 0.4, 0.3), 1.5 * s)
	rrect(irect(c, s, -29.0, -43.0, 58.0, 6.0), Color(0.96, 0.96, 0.97), 3)
	draw_colored_polygon(ellipse_pts(ip(c, s, 0.0, -42.0), 14.0 * s, 2.5 * s, 12), Color(0.80, 0.86, 0.92))
	draw_polyline(PackedVector2Array([ip(c, s, 0.0, -43.0), ip(c, s, 0.0, -52.0), ip(c, s, 8.0, -52.0), ip(c, s, 8.0, -47.0)]), Color(0.75, 0.77, 0.82), 3.0 * s, true)
	rrect(irect(c, s, -23.0, -104.0, 46.0, 54.0), fr, 4)
	var m0 := Color(0.80, 0.92, 0.98)
	var m1 := Color(0.60, 0.78, 0.90)
	var mr: Rect2 = irect(c, s, -19.0, -100.0, 38.0, 46.0)
	draw_polygon(PackedVector2Array([mr.position, Vector2(mr.end.x, mr.position.y), mr.end, Vector2(mr.position.x, mr.end.y)]), PackedColorArray([m0, m0, m1, m1]))
	draw_colored_polygon(PackedVector2Array([ip(c, s, -19.0, -100.0), ip(c, s, -4.0, -100.0), ip(c, s, -19.0, -72.0)]), Color(1, 1, 1, 0.35))

func item_chimney(v: int, c: Vector2, s: float):
	var col: Color = CHIM_COLS[v]
	draw_rect(irect(c, s, -13.0, -58.0, 26.0, 58.0), col)
	if v == 0:
		for k in 6:
			draw_line(ip(c, s, -13.0, -52.0 + float(k) * 9.0), ip(c, s, 13.0, -52.0 + float(k) * 9.0), col.darkened(0.3), 1.2)
	elif v == 1:
		for k in 5:
			draw_circle(ip(c, s, -6.0 + float(k % 3) * 6.0, -48.0 + float(k) * 10.0), 3.0 * s, col.darkened(0.18))
	draw_rect(irect(c, s, -17.0, -66.0, 34.0, 9.0), col.darkened(0.2))
	draw_rect(irect(c, s, -13.0, -58.0, 5.0, 58.0), Color(1, 1, 1, 0.10))
	for k in 3:
		var u: float = fposmod(time_acc * 0.4 + float(k) * 0.33, 1.0)
		draw_circle(ip(c, s, sin(u * 6.0) * 6.0, -72.0 - u * 50.0), (6.0 + u * 10.0) * s, Color(0.92, 0.92, 0.95, 0.5 * (1.0 - u)))

func item_tree(v: int, c: Vector2, s: float):
	ishadow(c, s, 44.0)
	draw_rect(irect(c, s, -7.0, -62.0, 14.0, 62.0), Color(0.38, 0.26, 0.17))
	draw_rect(irect(c, s, -7.0, -62.0, 5.0, 62.0), Color(1, 1, 1, 0.08))
	if v == 1:
		var pine := Color(0.10, 0.36, 0.22)
		for j in 3:
			var w: float = 46.0 - float(j) * 11.0
			var yb: float = -40.0 - float(j) * 32.0
			draw_colored_polygon(PackedVector2Array([ip(c, s, -w, yb), ip(c, s, w, yb), ip(c, s, 0.0, yb - 52.0)]), pine.lightened(0.07 * float(j)))
	else:
		var a: Color = Color(0.22, 0.58, 0.26)
		var b: Color = Color(0.32, 0.70, 0.32)
		if v == 2:
			a = Color(0.95, 0.60, 0.75)
			b = Color(1.0, 0.78, 0.86)
		draw_circle(ip(c, s, 0.0, -96.0), 46.0 * s, a)
		draw_circle(ip(c, s, -30.0, -72.0), 32.0 * s, a)
		draw_circle(ip(c, s, 30.0, -72.0), 32.0 * s, a)
		draw_circle(ip(c, s, -12.0, -108.0), 24.0 * s, b)
		draw_circle(ip(c, s, 18.0, -90.0), 18.0 * s, b)
		if v == 2:
			for k in 3:
				var u: float = fposmod(time_acc * 0.25 + float(k) * 0.33, 1.0)
				draw_circle(ip(c, s, -20.0 + float(k) * 22.0 + sin(u * 8.0) * 6.0, -60.0 + u * 60.0), 2.5 * s, Color(1.0, 0.8, 0.88, 1.0 - u))

func item_fence(v: int, c: Vector2, s: float):
	var col: Color = FENCE_COLS[v]
	if v == 2:
		rrect(irect(c, s, -60.0, -34.0, 120.0, 34.0), col, 14)
		for k in 14:
			draw_circle(ip(c, s, -54.0 + hash01(float(k) * 3.1) * 108.0, -28.0 + hash01(float(k) * 7.7) * 22.0), 3.0 * s, col.lightened(0.18))
		return
	draw_rect(irect(c, s, -60.0, -26.0, 120.0, 4.0), col.darkened(0.12))
	draw_rect(irect(c, s, -60.0, -12.0, 120.0, 4.0), col.darkened(0.12))
	for k in 7:
		var x: float = -54.0 + float(k) * 18.0
		draw_rect(irect(c, s, x - 5.0, -34.0, 10.0, 34.0), col)
		draw_colored_polygon(PackedVector2Array([ip(c, s, x - 5.0, -34.0), ip(c, s, x + 5.0, -34.0), ip(c, s, x, -41.0)]), col)
		draw_line(ip(c, s, x + 5.0, -34.0), ip(c, s, x + 5.0, 0.0), Color(0, 0, 0, 0.15), 1.0)

func item_flowers(v: int, c: Vector2, s: float):
	var pair: Array = FLOWER_COLS[v]
	var c1: Color = pair[0]
	var c2: Color = pair[1]
	draw_colored_polygon(ellipse_pts(ip(c, s, 0.0, -4.0), 62.0 * s, 9.0 * s, 20), Color(0.30, 0.20, 0.13))
	for k in 9:
		var x: float = -48.0 + float(k) * 12.0
		var hy: float = -24.0 - float(k % 3) * 7.0
		var sway: float = sin(time_acc * 1.5 + float(k)) * 1.5
		draw_line(ip(c, s, x, -4.0), ip(c, s, x + sway, hy), Color(0.20, 0.55, 0.25), 2.0 * s)
		draw_circle(ip(c, s, x + sway, hy), 6.0 * s, c1 if k % 2 == 0 else c2)
		draw_circle(ip(c, s, x + sway, hy), 2.2 * s, Color(1.0, 0.85, 0.2))

func item_mailbox(v: int, c: Vector2, s: float):
	var col: Color = MAIL_COLS[v]
	ishadow(c, s, 14.0)
	draw_rect(irect(c, s, -2.5, -52.0, 5.0, 52.0), Color(0.45, 0.32, 0.22))
	rrect(irect(c, s, -15.0, -68.0, 30.0, 18.0), col, 8)
	draw_rect(irect(c, s, -15.0, -60.0, 30.0, 10.0), col)
	draw_line(ip(c, s, 10.0, -68.0), ip(c, s, 10.0, -80.0), Color(0.95, 0.85, 0.2), 3.0 * s)
	draw_rect(irect(c, s, 10.0, -82.0, 10.0, 6.0), Color(0.95, 0.85, 0.2))
	draw_rect(irect(c, s, -15.0, -66.0, 4.0, 14.0), Color(1, 1, 1, 0.15))

func item_lights(v: int, c: Vector2, s: float):
	var col: Color = LIGHT_COLS[v]
	ishadow(c, s, 8.0)
	var pulse: float = 0.5 + 0.5 * sin(time_acc * 2.0)
	for k in 3:
		draw_circle(ip(c, s, 0.0, -66.0), (34.0 - float(k) * 9.0) * s, Color(col.r, col.g, col.b, 0.05 + 0.03 * pulse))
	draw_line(ip(c, s, 0.0, 0.0), ip(c, s, 0.0, -58.0), Color(0.18, 0.18, 0.22), 4.0 * s)
	rrect(irect(c, s, -8.0, -74.0, 16.0, 16.0), col.lightened(0.2), 4)
	draw_colored_polygon(PackedVector2Array([ip(c, s, -10.0, -74.0), ip(c, s, 10.0, -74.0), ip(c, s, 0.0, -82.0)]), Color(0.18, 0.18, 0.22))

func item_bench(v: int, c: Vector2, s: float):
	var col: Color = BENCH_COLS[v]
	ishadow(c, s, 36.0)
	rrect(irect(c, s, -32.0, -26.0, 64.0, 7.0), col, 2)
	rrect(irect(c, s, -32.0, -46.0, 64.0, 5.0), col, 2)
	rrect(irect(c, s, -32.0, -38.0, 64.0, 5.0), col, 2)
	draw_rect(irect(c, s, -30.0, -46.0, 4.0, 28.0), col.darkened(0.3))
	draw_rect(irect(c, s, 26.0, -46.0, 4.0, 28.0), col.darkened(0.3))
	draw_line(ip(c, s, -26.0, -19.0), ip(c, s, -26.0, 0.0), Color(0.2, 0.2, 0.24), 3.0 * s)
	draw_line(ip(c, s, 26.0, -19.0), ip(c, s, 26.0, 0.0), Color(0.2, 0.2, 0.24), 3.0 * s)

func draw_item(item: String, v: int, c: Vector2, s: float):
	match item:
		"sofa":
			item_sofa(v, c, s)
		"tv":
			item_tv(v, c, s)
		"plant":
			item_plant(v, c, s)
		"lamp":
			item_lamp(v, c, s)
		"rug":
			item_rug(v, c, s)
		"cabinet":
			item_cabinet(v, c, s)
		"table":
			item_table(v, c, s)
		"bed":
			item_bed(v, c, s)
		"wardrobe":
			item_wardrobe(v, c, s)
		"tub":
			item_tub(v, c, s)
		"sink":
			item_sink(v, c, s)
		"chimney":
			item_chimney(v, c, s)
		"tree":
			item_tree(v, c, s)
		"fence":
			item_fence(v, c, s)
		"flowers":
			item_flowers(v, c, s)
		"mailbox":
			item_mailbox(v, c, s)
		"lights":
			item_lights(v, c, s)
		"bench":
			item_bench(v, c, s)

# ---- patterns (used in the rooms and in the option pictures)

func draw_floor_pattern(r: Rect2, v: int):
	match v:
		0:
			draw_rect(r, Color(0.68, 0.48, 0.30))
			var rows: int = maxi(1, roundi(r.size.y / 8.0))
			var rh: float = r.size.y / float(rows)
			for i in rows:
				var y: float = r.position.y + float(i) * rh
				draw_line(Vector2(r.position.x, y), Vector2(r.end.x, y), Color(0.40, 0.26, 0.15, 0.7), 1.2)
				var x: float = r.position.x + (14.0 if i % 2 == 0 else 38.0)
				while x < r.end.x:
					draw_line(Vector2(x, y), Vector2(x, y + rh), Color(0.40, 0.26, 0.15, 0.6), 1.2)
					x += 48.0
			draw_rect(Rect2(r.position.x, r.position.y, r.size.x, 3.0), Color(1, 1, 1, 0.12))
		1:
			draw_rect(r, Color(0.90, 0.92, 0.94))
			var ts: float = 12.0
			for iy in ceili(r.size.y / ts):
				for ix in ceili(r.size.x / ts):
					if (ix + iy) % 2 == 0:
						var x0: float = r.position.x + float(ix) * ts
						var y0: float = r.position.y + float(iy) * ts
						draw_rect(Rect2(x0, y0, minf(ts, r.end.x - x0), minf(ts, r.end.y - y0)), Color(0.55, 0.62, 0.68))
		2:
			draw_rect(r, Color(0.55, 0.27, 0.36))
			var yy: float = r.position.y + 3.0
			while yy < r.end.y:
				draw_line(Vector2(r.position.x, yy), Vector2(r.end.x, yy), Color(1, 1, 1, 0.07), 1.5)
				yy += 4.0
			draw_rect(Rect2(r.position.x, r.position.y, r.size.x, 3.0), Color(1, 1, 1, 0.15))
		_:
			draw_rect(r, Color(0.50, 0.50, 0.52))
			for k in 14:
				draw_circle(Vector2(r.position.x + hash01(float(k) * 5.3) * r.size.x, r.position.y + hash01(float(k) * 9.1) * r.size.y), 1.3, Color(0, 0, 0, 0.2))

func draw_window(r: Rect2):
	draw_rect(r.grow(4.0), Color(0.96, 0.95, 0.92))
	var s0 := Color(0.50, 0.76, 0.96)
	var s1 := Color(0.86, 0.94, 1.0)
	draw_polygon(PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]), PackedColorArray([s0, s0, s1, s1]))
	draw_colored_polygon(ellipse_pts(r.position + Vector2(r.size.x * 0.66, r.size.y * 0.3), 9.0, 4.0, 10), Color(1, 1, 1, 0.9))
	var cc: Vector2 = r.get_center()
	draw_line(Vector2(cc.x, r.position.y), Vector2(cc.x, r.end.y), Color(0.96, 0.95, 0.92), 3.0)
	draw_line(Vector2(r.position.x, cc.y), Vector2(r.end.x, cc.y), Color(0.96, 0.95, 0.92), 3.0)
	draw_rect(Rect2(r.position.x - 6.0, r.end.y + 4.0, r.size.x + 12.0, 5.0), Color(0.88, 0.86, 0.82))
	draw_colored_polygon(PackedVector2Array([r.position, r.position + Vector2(r.size.x * 0.4, 0.0), r.position + Vector2(0.0, r.size.y * 0.5)]), Color(1, 1, 1, 0.22))

func draw_curtains(top: Vector2, w: float, h: float, v: int):
	var col: Color = CUR_COLS[v]
	draw_line(top + Vector2(-w * 0.5 - 6.0, 0.0), top + Vector2(w * 0.5 + 6.0, 0.0), Color(0.35, 0.25, 0.18), 3.0, true)
	for side in [-1.0, 1.0]:
		var sg: float = side
		var x0: float = top.x + sg * w * 0.5
		draw_colored_polygon(PackedVector2Array([Vector2(x0 + sg * 6.0, top.y), Vector2(x0 - sg * 16.0, top.y),
			Vector2(x0 - sg * 12.0, top.y + h), Vector2(x0 + sg * 4.0, top.y + h)]), col)
		draw_line(Vector2(x0 - sg * 8.0, top.y), Vector2(x0 - sg * 6.0, top.y + h), col.darkened(0.25), 2.0)
		draw_line(Vector2(x0 - sg * 2.0, top.y), Vector2(x0, top.y + h), col.lightened(0.2), 2.0)

func draw_art(c: Vector2, w: float, h: float, v: int):
	var fr := Rect2(c - Vector2(w, h) * 0.5, Vector2(w, h))
	draw_rect(fr.grow(3.0), Color(0.32, 0.22, 0.15))
	match v:
		0:
			draw_rect(fr, Color(0.55, 0.78, 0.95))
			draw_circle(fr.position + Vector2(w * 0.75, h * 0.28), h * 0.14, Color(1.0, 0.92, 0.5))
			draw_colored_polygon(PackedVector2Array([Vector2(fr.position.x, fr.end.y), Vector2(fr.position.x, fr.position.y + h * 0.68),
				Vector2(fr.position.x + w * 0.35, fr.position.y + h * 0.5), Vector2(fr.position.x + w * 0.7, fr.position.y + h * 0.72),
				Vector2(fr.end.x, fr.position.y + h * 0.6), fr.end]), Color(0.30, 0.62, 0.34))
		1:
			var a0 := Color(0.98, 0.62, 0.30)
			var a1 := Color(0.60, 0.30, 0.50)
			draw_polygon(PackedVector2Array([fr.position, Vector2(fr.end.x, fr.position.y), fr.end, Vector2(fr.position.x, fr.end.y)]), PackedColorArray([a1, a1, a0, a0]))
			draw_circle(fr.position + Vector2(w * 0.5, h * 0.7), h * 0.22, Color(1.0, 0.85, 0.4))
			draw_rect(Rect2(fr.position.x, fr.position.y + h * 0.7, w, h * 0.3), Color(0.20, 0.18, 0.32))
		_:
			draw_rect(fr, Color(0.95, 0.93, 0.88))
			draw_circle(fr.position + Vector2(w * 0.3, h * 0.4), h * 0.25, Color(0.90, 0.30, 0.35))
			draw_rect(Rect2(fr.position.x + w * 0.45, fr.position.y + h * 0.2, w * 0.3, h * 0.55), Color(0.25, 0.50, 0.85))
			draw_circle(fr.position + Vector2(w * 0.7, h * 0.72), h * 0.14, Color(0.98, 0.80, 0.25))

func draw_roof_swatch(r: Rect2, v: int):
	var col: Color = ROOF_COLS[v]
	rrect(r, col, 10)
	var row: int = 0
	var y: float = r.position.y + 12.0
	while y < r.end.y:
		draw_line(Vector2(r.position.x + 4.0, y), Vector2(r.end.x - 4.0, y), col.darkened(0.3), 2.0)
		var x: float = r.position.x + (10.0 if row % 2 == 0 else 22.0)
		while x < r.end.x - 4.0:
			draw_line(Vector2(x, y), Vector2(x, y - 12.0), col.darkened(0.2), 1.5)
			x += 24.0
		y += 12.0
		row += 1

func draw_sponge(c: Vector2, s: float):
	var cc: Vector2 = c + Vector2(0.0, sin(time_acc * 3.0) * 3.0)
	rrect(irect(cc, s, -34.0, -18.0, 68.0, 36.0), Color(0.98, 0.84, 0.25), 10)
	rrect(irect(cc, s, -34.0, -18.0, 68.0, 12.0), Color(0.35, 0.78, 0.45), 8)
	for k in 5:
		draw_circle(ip(cc, s, -24.0 + float(k) * 12.0, 6.0), 2.5 * s, Color(0.85, 0.68, 0.12))
	for k in 4:
		var u: float = fposmod(time_acc * 0.7 + float(k) * 0.25, 1.0)
		draw_arc(c + Vector2(-28.0 + float(k) * 19.0, -26.0 - u * 34.0) * s, (5.0 + float(k % 2) * 3.0) * s, 0.0, TAU, 14, Color(1, 1, 1, 0.8 * (1.0 - u)), 2.0, true)

# picture of an option (card in the list)
func draw_thumb(item: String, v: int, r: Rect2):
	var area := Rect2(r.position + Vector2(10.0, 8.0), Vector2(r.size.x - 20.0, 94.0))
	var cc: Vector2 = area.get_center()
	match item:
		"paint":
			rrect(area, PAINT_COLS[v], 10)
			draw_rect(Rect2(area.position.x + 4.0, area.end.y - 14.0, area.size.x - 8.0, 10.0), Color(1, 1, 1, 0.55))
			draw_rect(Rect2(area.position.x + 12.0, area.position.y + 10.0, 14.0, 60.0), Color(1, 1, 1, 0.14))
		"floor":
			draw_floor_pattern(area, v)
		"curtain":
			rrect(area, Color(0.88, 0.90, 0.95), 10)
			draw_window(Rect2(cc - Vector2(24.0, 26.0), Vector2(48.0, 52.0)))
			draw_curtains(Vector2(cc.x, area.position.y + 12.0), 86.0, 70.0, v)
		"art":
			rrect(area, Color(0.90, 0.88, 0.82), 10)
			draw_art(cc, 76.0, 58.0, v)
		"roof":
			draw_roof_swatch(area, v)
		_:
			var outdoor: bool = item in OUTDOOR_ITEMS
			rrect(area, Color(0.62, 0.82, 0.96) if outdoor else Color(0.88, 0.89, 0.93), 10)
			draw_rect(Rect2(area.position.x + 3.0, area.end.y - 18.0, area.size.x - 6.0, 15.0),
				Color(0.36, 0.66, 0.30) if outdoor else Color(0.78, 0.68, 0.55))
			var ts: float = THUMB_S.get(item, 1.2)
			draw_item(item, v, Vector2(cc.x, area.end.y - 8.0), ts)

func draw_step_icon(st: Array, r: Rect2):
	if str(st[1]) == "clean":
		draw_sponge(r.get_center(), 1.6)
	else:
		draw_thumb(str(st[1]), 0, r)

# ---- the house picture

func draw_dirt(r: Rect2, slot: int):
	draw_rect(r, Color(0.22, 0.17, 0.10, 0.30))
	for k in 8:
		var hx: float = r.position.x + hash01(float(k) * 12.9898 + float(slot) * 7.7) * r.size.x
		var hl: float = 12.0 + hash01(float(k) * 4.1 + float(slot)) * 40.0
		draw_line(Vector2(hx, r.position.y), Vector2(hx + 2.0, r.position.y + hl), Color(0.15, 0.10, 0.05, 0.22), 3.0)
	for k in 7:
		var bx: float = r.position.x + 10.0 + hash01(float(k) * 8.3 + float(slot) * 3.3) * (r.size.x - 20.0)
		var by: float = r.position.y + 118.0 + hash01(float(k) * 2.9 + float(slot)) * 16.0
		draw_colored_polygon(ellipse_pts(Vector2(bx, by), 10.0 + hash01(float(k)) * 14.0, 3.0 + hash01(float(k) + 4.0) * 2.0, 10), Color(0.12, 0.08, 0.04, 0.35))
	for side in [0, 1]:
		var cx: float = r.position.x if side == 0 else r.end.x
		var dr: float = 1.0 if side == 0 else -1.0
		for k in 4:
			var a: float = float(k) * 0.4 + 0.1
			draw_line(Vector2(cx, r.position.y), Vector2(cx + dr * cos(a) * 44.0, r.position.y + sin(a) * 44.0), Color(1, 1, 1, 0.55), 1.2)
		for rad in [16.0, 30.0]:
			var pts := PackedVector2Array()
			for k in 5:
				var a2: float = float(k) * 0.4 + 0.1
				var rr: float = rad
				pts.append(Vector2(cx + dr * cos(a2) * rr, r.position.y + sin(a2) * rr))
			draw_polyline(pts, Color(1, 1, 1, 0.45), 1.0)
	draw_circle(Vector2(r.position.x + 30.0, r.end.y - 14.0), 5.0, Color(0.75, 0.75, 0.72))
	draw_circle(Vector2(r.end.x - 40.0, r.end.y - 12.0), 4.0, Color(0.70, 0.70, 0.66))

func draw_room(slot: int):
	var r: Rect2 = room_rect(slot)
	var paint: int = house_get(slot, "paint")
	var wall := Color(0.80, 0.78, 0.74)
	if paint >= 0:
		wall = PAINT_COLS[paint]
	var w0: Color = wall.lightened(0.10)
	var w1: Color = wall.darkened(0.06)
	draw_polygon(PackedVector2Array([r.position, Vector2(r.end.x, r.position.y),
		Vector2(r.end.x, r.position.y + 116.0), Vector2(r.position.x, r.position.y + 116.0)]),
		PackedColorArray([w0, w0, w1, w1]))
	if paint >= 0:
		for k in 11:
			draw_rect(Rect2(r.position.x + float(k) * 20.0 + 10.0, r.position.y, 10.0, 116.0), Color(1, 1, 1, 0.05))
	draw_floor_pattern(Rect2(r.position.x, r.position.y + 116.0, r.size.x, 24.0), house_get(slot, "floor"))
	draw_rect(Rect2(r.position.x, r.position.y + 110.0, r.size.x, 6.0), wall.darkened(0.28))
	var wx: float = WIN_X[slot]
	var wr := Rect2(r.position + Vector2(wx - 22.0, 18.0), Vector2(44.0, 50.0))
	draw_window(wr)
	if house_clean[slot]:
		draw_colored_polygon(PackedVector2Array([Vector2(wr.position.x, wr.end.y), Vector2(wr.end.x, wr.end.y),
			Vector2(wr.end.x + 50.0, r.position.y + 118.0), Vector2(wr.position.x + 10.0, r.position.y + 118.0)]), Color(1.0, 0.95, 0.7, 0.10))
	var cur: int = house_get(slot, "curtain")
	if cur >= 0:
		draw_curtains(Vector2(wx, wr.position.y - 6.0), 52.0, 64.0, cur)
	var art: int = house_get(slot, "art")
	if art >= 0:
		var ap: Array = ART_POS[slot]
		var ac: Vector2 = r.position + Vector2(float(ap[0]), float(ap[1]))
		draw_art(ac, float(ap[2]), float(ap[3]), art)
	for item in ROOM_ITEMS:
		var it: String = item
		var v: int = house_get(slot, it)
		if v >= 0:
			var pl: Array = item_place(slot, it)
			var pc: Vector2 = pl[0]
			draw_item(it, v, pc, float(pl[1]))
	if not house_clean[slot]:
		draw_dirt(r, slot)

func draw_lawn():
	var o: Vector2 = HOUSE_O
	var clean: bool = house_clean[5]
	var g0: Color = Color(0.36, 0.70, 0.28) if clean else Color(0.42, 0.50, 0.22)
	var g1: Color = Color(0.24, 0.52, 0.20) if clean else Color(0.28, 0.34, 0.15)
	draw_polygon(PackedVector2Array([o + Vector2(0.0, 440.0), o + Vector2(HOUSE_W, 440.0),
		o + Vector2(HOUSE_W, HOUSE_H), o + Vector2(0.0, HOUSE_H)]), PackedColorArray([g0, g0, g1, g1]))
	if clean:
		for k in 8:
			if k % 2 == 0:
				draw_rect(Rect2(o + Vector2(float(k) * 80.0, 440.0), Vector2(80.0, 160.0)), Color(1, 1, 1, 0.05))
	else:
		for k in 30:
			var x: float = o.x + 14.0 + hash01(float(k) * 12.1) * 612.0
			var y: float = o.y + 456.0 + hash01(float(k) * 5.7) * 128.0
			var gc := Color(0.62, 0.66, 0.26)
			draw_line(Vector2(x, y), Vector2(x - 5.0, y - 18.0), gc, 2.0, true)
			draw_line(Vector2(x, y), Vector2(x + 2.0, y - 23.0), gc.darkened(0.15), 2.0, true)
			draw_line(Vector2(x, y), Vector2(x + 8.0, y - 15.0), gc, 2.0, true)
		for k in 4:
			var tx: float = o.x + 210.0 + hash01(float(k) * 3.3) * 330.0
			var ty: float = o.y + 540.0 + hash01(float(k) * 8.8) * 40.0
			draw_circle(Vector2(tx, ty), 5.0, Color(0.78, 0.78, 0.74))
			draw_circle(Vector2(tx - 1.5, ty - 1.5), 2.0, Color(1, 1, 1, 0.5))

func draw_house_roof():
	var o: Vector2 = HOUSE_O
	var v: int = house_get(4, "roof")
	var base := Color(0.40, 0.38, 0.40)
	if v >= 0:
		base = ROOF_COLS[v]
	var p0: Vector2 = o + Vector2(105.0, 164.0)
	var p1: Vector2 = o + Vector2(350.0, 46.0)
	var p2: Vector2 = o + Vector2(595.0, 164.0)
	draw_colored_polygon(PackedVector2Array([p0, p1, p2]), base)
	draw_colored_polygon(PackedVector2Array([p0, p1, o + Vector2(350.0, 164.0)]), Color(1, 1, 1, 0.07))
	var row: int = 0
	var y: float = 58.0
	while y < 160.0:
		var half: float = (y - 46.0) * 2.076
		var xl: float = o.x + 350.0 - half
		var xr: float = o.x + 350.0 + half
		draw_line(Vector2(xl, o.y + y), Vector2(xr, o.y + y), base.darkened(0.28), 2.0)
		var x: float = xl + (12.0 if row % 2 == 0 else 24.0)
		while x < xr - 4.0:
			draw_line(Vector2(x, o.y + y), Vector2(x, o.y + y - 14.0), base.darkened(0.18), 1.5)
			x += 24.0
		y += 14.0
		row += 1
	draw_polyline(PackedVector2Array([p0, p1, p2]), base.lightened(0.2), 6.0, true)
	draw_rect(Rect2(o + Vector2(105.0, 160.0), Vector2(490.0, 8.0)), base.darkened(0.4))
	if not house_clean[4]:
		draw_colored_polygon(PackedVector2Array([p0, p1, p2]), Color(0.10, 0.12, 0.08, 0.22))
		for k in 16:
			var my: float = 70.0 + hash01(float(k) * 6.1) * 88.0
			var half2: float = (my - 46.0) * 2.076
			var mx: float = o.x + 350.0 + (hash01(float(k) * 2.2) * 2.0 - 1.0) * half2 * 0.9
			draw_colored_polygon(ellipse_pts(Vector2(mx, o.y + my), 14.0 + hash01(float(k)) * 12.0, 5.0 + hash01(float(k) + 2.0) * 4.0, 10), Color(0.25, 0.48, 0.18, 0.7))
		for k in 8:
			var ly: float = 96.0 + hash01(float(k) * 1.7) * 60.0
			var half3: float = (ly - 46.0) * 2.076
			draw_circle(Vector2(o.x + 350.0 + (hash01(float(k) * 9.7) * 2.0 - 1.0) * half3 * 0.85, o.y + ly), 3.0, Color(0.50, 0.32, 0.12))

func draw_house_fx():
	var t: float = time_acc - house_fx_t
	if t < 0.0 or t > 1.6:
		return
	var p: float = t / 1.6
	var c: Vector2 = house_fx_pos
	draw_arc(c, 20.0 + p * 120.0, 0.0, TAU, 40, Color(1, 1, 0.6, 1.0 - p), 5.0 * (1.0 - p) + 1.0, true)
	for k in 10:
		var a: float = float(k) / 10.0 * TAU + 0.3
		draw_sparkle(c + Vector2(cos(a), sin(a)) * (30.0 + p * 90.0), 12.0 * (1.0 - p) + 2.0, Color(1, 1, 0.8, 1.0 - p))
	if house_fx_clean:
		var r: Rect2 = slot_rect(house_fx_slot)
		for k in 16:
			var bx: float = r.position.x + hash01(float(k) * 3.7) * r.size.x
			var by: float = r.end.y - p * (r.size.y + 20.0) - float(k % 5) * 8.0
			if by > r.position.y - 20.0:
				draw_arc(Vector2(bx, by), 5.0 + float(k % 3) * 2.0, 0.0, TAU, 12, Color(1, 1, 1, 0.85 * (1.0 - p)), 2.0, true)

func draw_house_scene():
	var o: Vector2 = HOUSE_O
	var sky0 := Color(0.42, 0.70, 0.95)
	var sky1 := Color(0.82, 0.92, 1.0)
	draw_polygon(PackedVector2Array([o, o + Vector2(HOUSE_W, 0.0), o + Vector2(HOUSE_W, 440.0), o + Vector2(0.0, 440.0)]),
		PackedColorArray([sky0, sky0, sky1, sky1]))
	var sp: Vector2 = o + Vector2(70.0, 62.0)
	for k in 4:
		draw_circle(sp, 54.0 - float(k) * 11.0, Color(1.0, 0.95, 0.6, 0.12))
	draw_circle(sp, 20.0, Color(1.0, 0.96, 0.7))
	for k in 3:
		var cx: float = o.x + 40.0 + fposmod(time_acc * 5.0 + float(k) * 190.0, 520.0)
		var cy: float = o.y + 52.0 + float(k) * 32.0
		draw_colored_polygon(ellipse_pts(Vector2(cx, cy), 44.0, 13.0, 14), Color(1, 1, 1, 0.85))
		draw_colored_polygon(ellipse_pts(Vector2(cx + 20.0, cy - 8.0), 26.0, 12.0, 14), Color(1, 1, 1, 0.85))
	draw_hill(o.x, o.x + 330.0, o.y + 446.0, 70.0, Color(0.55, 0.75, 0.62))
	draw_hill(o.x + 300.0, o.x + HOUSE_W, o.y + 446.0, 60.0, Color(0.48, 0.70, 0.56))
	draw_lawn()

	# tree stands behind the house
	var tv: int = house_get(5, "tree")
	if tv >= 0:
		var tp: Array = item_place(5, "tree")
		var tc: Vector2 = tp[0]
		draw_item("tree", tv, tc, float(tp[1]))

	# foundation, frame and rooms
	draw_rect(Rect2(o + Vector2(112.0, 446.0), Vector2(476.0, 16.0)), Color(0.46, 0.46, 0.50))
	for k in 12:
		draw_line(o + Vector2(112.0 + float(k) * 40.0, 446.0), o + Vector2(112.0 + float(k) * 40.0, 462.0), Color(0, 0, 0, 0.2), 1.5)
	draw_rect(Rect2(o + Vector2(120.0, 152.0), Vector2(460.0, 296.0)), Color(0.40, 0.28, 0.20))
	for slot in 4:
		draw_room(slot)
	draw_rect(Rect2(o + Vector2(346.0, 160.0), Vector2(8.0, 280.0)), Color(0.40, 0.28, 0.20))
	draw_rect(Rect2(o + Vector2(130.0, 296.0), Vector2(440.0, 8.0)), Color(0.36, 0.25, 0.18))

	var chv: int = house_get(4, "chimney")
	if chv >= 0:
		var cp: Array = item_place(4, "chimney")
		var cpos: Vector2 = cp[0]
		draw_item("chimney", chv, cpos, float(cp[1]))
	draw_house_roof()

	# garden items in front of the house
	for it in ["flowers", "mailbox", "bench", "lights"]:
		var nm: String = it
		var v: int = house_get(5, nm)
		if v >= 0:
			var pl: Array = item_place(5, nm)
			var pc: Vector2 = pl[0]
			draw_item(nm, v, pc, float(pl[1]))
			if nm == "lights":
				draw_item(nm, v, Vector2(o.x + 500.0, pc.y), float(pl[1]))
	var fv: int = house_get(5, "fence")
	if fv >= 0:
		for k in 4:
			draw_item("fence", fv, o + Vector2(210.0 + float(k) * 120.0, 598.0), 1.0)

	draw_human(o + Vector2(60.0, 592.0), 0.62, house_pending())

	# what the open step is about
	if house_pending():
		var st: Array = HOUSE_STEPS[house_done]
		var slot: int = st[0]
		var item: String = st[1]
		var pulse: float = 0.5 + 0.5 * sin(time_acc * 5.0)
		if item == "clean":
			draw_rect(slot_rect(slot), Color(1.0, 0.9, 0.4, 0.25 + 0.4 * pulse), false, 4.0)
		else:
			var mp: Vector2 = house_marker(slot, item)
			if house_sel < 0:
				draw_circle(mp, 20.0 + 3.0 * pulse, Color(1.0, 0.85, 0.25, 0.92))
				draw_line(mp + Vector2(-8.0, 0.0), mp + Vector2(8.0, 0.0), Color.WHITE, 4.0, true)
				draw_line(mp + Vector2(0.0, -8.0), mp + Vector2(0.0, 8.0), Color.WHITE, 4.0, true)
			else:
				draw_arc(mp, 34.0 + 5.0 * pulse, 0.0, TAU, 32, Color(1.0, 0.9, 0.4, 0.9), 3.0, true)
	draw_house_fx()
	draw_rect(Rect2(o, Vector2(HOUSE_W, HOUSE_H)), Color(1, 1, 1, 0.35), false, 3.0)

# ---- a person who looks real (proportions, shading, folds)

func draw_human(base: Vector2, s: float, talking: bool):
	draw_set_transform(base, 0.0, Vector2(s, s))
	var skin := Color(0.93, 0.74, 0.60)
	var skin_d := Color(0.80, 0.58, 0.44)
	var hair := Color(0.16, 0.11, 0.08)
	var shirt := Color(0.16, 0.55, 0.62)
	var shirt_d := Color(0.10, 0.40, 0.47)
	var jeans := Color(0.20, 0.28, 0.46)
	var jeans_d := Color(0.13, 0.19, 0.34)
	var t: float = time_acc
	var br: float = sin(t * 1.6) * 1.2

	draw_colored_polygon(ellipse_pts(Vector2(0, 2), 54.0, 9.0, 18), Color(0, 0, 0, 0.28))
	# legs and shoes
	draw_colored_polygon(PackedVector2Array([Vector2(-27, -176), Vector2(-2, -176), Vector2(-5, -10), Vector2(-25, -10)]), jeans)
	draw_colored_polygon(PackedVector2Array([Vector2(2, -176), Vector2(27, -176), Vector2(25, -10), Vector2(5, -10)]), jeans)
	draw_colored_polygon(PackedVector2Array([Vector2(8, -176), Vector2(27, -176), Vector2(25, -10), Vector2(14, -10)]), Color(0, 0, 0, 0.14))
	draw_line(Vector2(-14, -150), Vector2(-16, -60), jeans_d, 2.0, true)
	draw_colored_polygon(ellipse_pts(Vector2(-18, -6), 18.0, 8.0, 14), Color(0.93, 0.93, 0.95))
	draw_colored_polygon(ellipse_pts(Vector2(18, -6), 18.0, 8.0, 14), Color(0.93, 0.93, 0.95))
	draw_rect(Rect2(-36, -2, 36, 3), Color(0.55, 0.55, 0.60))
	draw_rect(Rect2(0, -2, 36, 3), Color(0.55, 0.55, 0.60))

	# arms (behind the torso edge)
	draw_capsule(Vector2(-42, -246), Vector2(-49, -218), 22.0, shirt)
	draw_capsule(Vector2(-49, -218), Vector2(-48, -160), 15.0, skin)
	draw_circle(Vector2(-48, -152), 9.0, skin)
	var wave: float = absf(sin(t * 5.0)) * 22.0 if talking else 0.0
	var hand: Vector2 = Vector2(68, -176 - wave * 2.2) if talking else Vector2(48, -152)
	var elbow: Vector2 = Vector2(62, -208) if talking else Vector2(49, -218)
	draw_capsule(Vector2(42, -246), elbow, 22.0, shirt)
	draw_capsule(elbow, hand, 15.0, skin)
	draw_circle(hand, 9.0, skin)

	# torso, belt, folds
	draw_colored_polygon(PackedVector2Array([Vector2(-42, -258 + br), Vector2(42, -258 + br), Vector2(31, -172), Vector2(-31, -172)]), shirt)
	draw_colored_polygon(PackedVector2Array([Vector2(2, -258 + br), Vector2(42, -258 + br), Vector2(31, -172), Vector2(2, -172)]), Color(0, 0, 0, 0.14))
	draw_line(Vector2(-14, -236), Vector2(-20, -190), shirt_d, 2.0, true)
	draw_line(Vector2(-4, -226), Vector2(-8, -184), shirt_d, 2.0, true)
	draw_line(Vector2(16, -232), Vector2(20, -190), shirt_d, 2.0, true)
	draw_rect(Rect2(-31, -178, 62, 7), Color(0.12, 0.09, 0.07))
	draw_rect(Rect2(-5, -179, 10, 9), Color(0.85, 0.72, 0.35))

	# neck, collar
	draw_rect(Rect2(-9, -276 + br, 18, 22), skin_d)
	draw_colored_polygon(PackedVector2Array([Vector2(-11, -262 + br), Vector2(11, -262 + br), Vector2(0, -242)]), skin)
	draw_colored_polygon(PackedVector2Array([Vector2(-20, -262 + br), Vector2(-4, -258 + br), Vector2(-14, -240)]), shirt_d)
	draw_colored_polygon(PackedVector2Array([Vector2(20, -262 + br), Vector2(4, -258 + br), Vector2(14, -240)]), shirt_d)

	# head
	draw_circle(Vector2(-24, -298 + br), 5.0, skin_d)
	draw_circle(Vector2(24, -298 + br), 5.0, skin_d)
	draw_colored_polygon(ellipse_pts(Vector2(0, -298 + br), 24.0, 29.0, 28), skin)
	draw_colored_polygon(PackedVector2Array([Vector2(8, -326 + br), Vector2(22, -312 + br), Vector2(24, -292 + br),
		Vector2(18, -274 + br), Vector2(8, -270 + br)]), Color(0, 0, 0, 0.08))
	# hair
	var hp := PackedVector2Array()
	for k in 15:
		var a: float = PI + PI * float(k) / 14.0
		hp.append(Vector2(cos(a) * 26.0, -304.0 + br + sin(a) * 31.0))
	hp.append(Vector2(24, -300 + br))
	hp.append(Vector2(16, -314 + br))
	hp.append(Vector2(0, -310 + br))
	hp.append(Vector2(-14, -316 + br))
	hp.append(Vector2(-24, -300 + br))
	draw_colored_polygon(hp, hair)
	# face
	draw_line(Vector2(-16, -307 + br), Vector2(-5, -309 + br), hair, 3.0, true)
	draw_line(Vector2(5, -309 + br), Vector2(16, -307 + br), hair, 3.0, true)
	var blink: bool = fmod(t, 4.0) < 0.12
	for sx in [-1.0, 1.0]:
		var sg: float = sx
		var ec := Vector2(sg * 10.0, -299.0 + br)
		if blink:
			draw_line(ec + Vector2(-6, 0), ec + Vector2(6, 0), hair, 2.0, true)
		else:
			draw_colored_polygon(ellipse_pts(ec, 6.5, 3.8, 12), Color.WHITE)
			draw_circle(ec + Vector2(sg * 0.8, 0.0), 2.8, Color(0.30, 0.20, 0.12))
			draw_circle(ec + Vector2(sg * 0.8 - 0.8, -0.8), 1.0, Color.WHITE)
	draw_polyline(PackedVector2Array([Vector2(1, -299 + br), Vector2(-2, -287 + br), Vector2(2, -285 + br)]), skin_d, 2.0, true)
	if talking:
		var op: float = 1.5 + 3.5 * absf(sin(t * 12.0))
		draw_colored_polygon(ellipse_pts(Vector2(0, -276 + br), 6.0, op, 12), Color(0.45, 0.10, 0.12))
	else:
		draw_arc(Vector2(0, -280 + br), 8.0, 0.3, PI - 0.3, 10, Color(0.55, 0.22, 0.22), 2.2, true)
	draw_colored_polygon(PackedVector2Array([Vector2(-16, -276 + br), Vector2(16, -276 + br), Vector2(10, -268 + br), Vector2(-10, -268 + br)]), Color(0.2, 0.12, 0.08, 0.10))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

# ---- the house screen

func draw_house_panel():
	draw_style_box(card_style, Rect2(30.0, 782.0, 660.0, 336.0))
	var txt: String = house_say()
	if txt != house_text_cache:
		house_text_cache = txt
		house_lines = wrap_text(txt, 600.0, 24)
	text_l("ALEX", Vector2(60.0, 822.0), 20, Color(1.0, 0.9, 0.4))
	for li in mini(house_lines.size(), 2):
		var ln: String = house_lines[li]
		text_l(ln, Vector2(60.0, 852.0 + float(li) * 30.0), 24, Color(1, 1, 1, 0.95))
	if house_pending():
		var st: Array = HOUSE_STEPS[house_done]
		var item: String = st[1]
		if item == "clean":
			draw_sponge(Vector2(115.0, 985.0), 1.4)
			draw_button(house_clean_rect, "CLEAN NOW", 38, Color(0.2, 0.7, 0.4))
		else:
			var labels: Array = ITEM_LABELS.get(item, ["A", "B", "C"])
			for i in 3:
				var r: Rect2 = house_card_rect(i)
				draw_style_box(row_styles["me"] if i == house_sel else row_styles["normal"], r)
				draw_thumb(item, i, r)
				var lb: String = labels[i]
				text_c(lb, r.position.y + 132.0, 19, Color.WHITE, r.position.x, r.size.x)
			if house_sel >= 0:
				draw_button(house_place_rect, "PLACE IT", 30, Color(0.2, 0.7, 0.4))
			else:
				draw_button(house_place_rect, "TAP AN OPTION", 26, Color(0.4, 0.4, 0.5))
	else:
		if house_done < HOUSE_STEPS.size():
			var nx: Array = HOUSE_STEPS[house_done]
			text_c("Next job: " + str(nx[2]), 960.0, 26, Color(1, 1, 1, 0.8), 30.0, 660.0)
			text_c("Clear level " + str(house_done + 1) + " to unlock it", 1002.0, 22, Color(1.0, 0.9, 0.4), 30.0, 660.0)
		else:
			text_c("HOUSE COMPLETE!", 975.0, 40, Color(1.0, 0.9, 0.4), 30.0, 660.0)

func draw_house():
	draw_page_header("MY HOUSE", "Upgrades  " + str(house_done) + " / " + str(HOUSE_STEPS.size()))
	draw_house_scene()
	draw_house_panel()

# popup shown after clearing a level: the new house job (no longer used)
func draw_unlock_card():
	if win_new_part < 0 or win_new_part >= HOUSE_STEPS.size():
		return
	var st: Array = HOUSE_STEPS[win_new_part]
	var card := Rect2(110.0, 330.0, 500.0, 430.0)
	draw_style_box(card_style, card)
	text_c("NEW HOUSE JOB!", 392.0, 38, Color(1.0, 0.9, 0.4), card.position.x, card.size.x)
	text_c(str(st[2]), 438.0, 28, Color.WHITE, card.position.x, card.size.x)
	draw_step_icon(st, Rect2(250.0, 470.0, 220.0, 146.0))
	text_c("Open the House tab to do it", 690.0, 24, Color(1, 1, 1, 0.8), card.position.x, card.size.x)
	if current_level == LB_UNLOCK_LEVEL:
		text_c("LEADERBOARD UNLOCKED!", 735.0, 28, Color(0.6, 1.0, 0.7), card.position.x, card.size.x)

# small message above the tab bar
func draw_toast():
	if toast_t <= 0.0:
		return
	var lines: Array = wrap_text(toast_text, 540.0, 24)
	var h: float = 34.0 + float(lines.size()) * 32.0
	var r := Rect2(50.0, tab_rect.position.y - 38.0 - h, 620.0, h)
	draw_style_box(card_style, r)
	var font: Font = ThemeDB.fallback_font
	for li in lines.size():
		var ln: String = lines[li]
		draw_string(font, Vector2(r.position.x, r.position.y + 40.0 + float(li) * 32.0), ln,
			HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 24, Color(1.0, 0.92, 0.6))

# ---------------------------------------------------------------- bottom tab bar

func draw_tab_icon(i: int, c: Vector2, s: float, col: Color, hole: Color):
	var h: float = s * 0.5
	match i:
		0:
			# trophy
			draw_colored_polygon(PackedVector2Array([
				c + Vector2(-0.8 * h, -h), c + Vector2(0.8 * h, -h), c + Vector2(0.6 * h, 0.2 * h),
				c + Vector2(0.3 * h, 0.5 * h), c + Vector2(-0.3 * h, 0.5 * h),
				c + Vector2(-0.6 * h, 0.2 * h)]), col)
			draw_arc(c + Vector2(-0.8 * h, -0.45 * h), 0.4 * h, PI / 2.0, 3.0 * PI / 2.0, 10, col, 3.0, true)
			draw_arc(c + Vector2(0.8 * h, -0.45 * h), 0.4 * h, -PI / 2.0, PI / 2.0, 10, col, 3.0, true)
			draw_rect(Rect2(c.x - 0.12 * h, c.y + 0.5 * h, 0.24 * h, 0.35 * h), col)
			draw_rect(Rect2(c.x - 0.5 * h, c.y + 0.85 * h, h, 0.22 * h), col)
			draw_circle(c + Vector2(0.0, -0.35 * h), 0.22 * h, hole)
		1:
			# map pin
			var pc: Vector2 = c + Vector2(0.0, -0.3 * h)
			draw_colored_polygon(PackedVector2Array([
				pc + Vector2(-0.62 * h, 0.25 * h), pc + Vector2(0.62 * h, 0.25 * h),
				c + Vector2(0.0, 1.05 * h)]), col)
			draw_circle(pc, 0.7 * h, col)
			draw_circle(pc, 0.28 * h, hole)
		2:
			# house
			draw_colored_polygon(PackedVector2Array([c + Vector2(-1.1 * h, -0.05 * h),
				c + Vector2(0.0, -1.0 * h), c + Vector2(1.1 * h, -0.05 * h)]), col)
			draw_rect(Rect2(c.x - 0.8 * h, c.y - 0.05 * h, 1.6 * h, 1.0 * h), col)
			draw_rect(Rect2(c.x - 0.2 * h, c.y + 0.4 * h, 0.4 * h, 0.55 * h), hole)
		3:
			# gear
			for k in 8:
				var a: float = float(k) / 8.0 * TAU
				var d := Vector2(cos(a), sin(a))
				draw_line(c + d * 0.55 * h, c + d * 1.02 * h, col, 0.42 * h, true)
			draw_circle(c, 0.75 * h, col)
			draw_circle(c, 0.3 * h, hole)

func draw_tab_bar():
	var bar: Rect2 = tab_rect
	var tab_w: float = bar.size.x / 2.0
	draw_style_box(tab_style, bar)

	# colour of the floating bubble blends between the two tabs while it moves
	var pos: float = clampf(tab_pos, 0.0, 1.0)
	var bub_col: Color = TAB_COLORS[0].lerp(TAB_COLORS[1], pos)
	var bcx: float = bar.position.x + tab_w * (pos + 0.5)
	var bcy: float = bar.position.y + 22.0

	# glow under the bubble
	for k in 5:
		draw_circle(Vector2(bcx, bcy + 6.0), 78.0 - float(k) * 9.0,
			Color(bub_col.r, bub_col.g, bub_col.b, 0.06))
	# dark ring that makes the bubble look cut into the bar
	draw_circle(Vector2(bcx, bcy), 60.0, TAB_BAR_COL)
	draw_circle(Vector2(bcx, bcy), 52.0, bub_col.darkened(0.3))
	draw_circle(Vector2(bcx, bcy - 2.0), 49.0, bub_col)
	draw_circle(Vector2(bcx - 15.0, bcy - 20.0), 17.0, Color(1, 1, 1, 0.28))
	draw_arc(Vector2(bcx, bcy), 52.0, 0.0, TAU, 40, Color(1, 1, 1, 0.55), 3.0, true)
	# twinkles around the bubble
	var tw1: float = 0.5 + 0.5 * sin(time_acc * 3.0)
	var tw2: float = 0.5 + 0.5 * sin(time_acc * 3.0 + 2.0)
	draw_sparkle(Vector2(bcx + 46.0, bcy - 40.0), 4.0 + 5.0 * tw1, Color(1, 1, 1, 0.5 + 0.5 * tw1))
	draw_sparkle(Vector2(bcx - 52.0, bcy - 26.0), 3.0 + 4.0 * tw2, Color(1, 1, 1, 0.4 + 0.5 * tw2))

	var labels: Array = ["Story", "Settings"]
	var icons: Array = [1, 3]      # 1 = map pin, 3 = gear (see draw_tab_icon)
	for i in 2:
		var a: float = clampf(1.0 - absf(pos - float(i)), 0.0, 1.0)
		var cx: float = bar.position.x + tab_w * (float(i) + 0.5)
		var cy: float = lerpf(bar.position.y + 52.0, bcy, a)
		var isz: float = lerpf(40.0, 46.0, a)
		var icol := Color(1, 1, 1, lerpf(0.55, 1.0, a))
		var hole: Color = TAB_BAR_COL.lerp(bub_col, a)
		draw_tab_icon(int(icons[i]), Vector2(cx, cy), isz, icol, hole)
		text_c(labels[i], bar.end.y - 16.0, 20, icol, cx - tab_w / 2.0, tab_w)
