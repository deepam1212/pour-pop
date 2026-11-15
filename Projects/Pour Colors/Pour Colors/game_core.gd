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
const SCREEN_H = 1280.0

# levels and ads
const TOTAL_LEVELS = 200
const AD_EVERY = 5
const AD_TIME = 3.0

# links used by the settings screen. Leave a URL empty "" to show the
# built-in text page instead (privacy / terms) or to do nothing (rate).
const PRIVACY_URL = ""
const TERMS_URL = ""
const RATE_URL = ""
const SUPPORT_EMAIL = "support@example.com"
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
const DOC_PRIVACY = "Your privacy matters to us.\n\nMagic Sort saves your game progress and settings only on your device.\n\nWe do not ask for or collect personal information such as your name, e-mail address or location.\n\nIf ads are shown, our advertising partner may use your device's advertising ID to show ads. This is described in the partner's own privacy policy. You can reset or limit the advertising ID in your device settings.\n\nIf you have questions, write to us at the support address in Settings."
const DOC_TERMS = "By installing or playing Magic Sort you agree to these terms.\n\n1. The game is provided as is, for your personal, non-commercial entertainment.\n\n2. You may not copy, modify, sell or reverse engineer the game.\n\n3. The game may show ads and may be updated, changed or removed at any time.\n\n4. We are not responsible for any loss of progress or for problems caused by your device.\n\n5. We may update these terms. Continuing to play means you accept the new terms."
const DOC_ABOUT = "Magic Sort is a relaxing color-sorting puzzle.\n\nPour liquids, sand and gas between the bottles until every bottle holds just one color.\n\n200 levels are waiting for you, from easy to tricky.\n\nThank you for playing!"

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
var ad_timer: float = 0.0

# buttons
var menu_rect := Rect2(30, 40, 90, 90)
var undo_rect := Rect2(150, 1100, 170, 110)
var restart_rect := Rect2(400, 1100, 170, 110)
var ad_btn := Rect2(210, 740, 300, 90)
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
	["about", "About Magic Sort", "link", Color(0.20, 0.85, 0.88)],
	["rate", "Rate Us", "link", Color(0.98, 0.70, 0.15)],
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
	# portrait only (also set in Project Settings, see notes)
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
	go_menu()

func _exit_tree():
	if music_thread != null and music_thread.is_started():
		music_thread.wait_to_finish()

# ---------------------------------------------------------------- progress

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

	if screen == "ad":
		ad_timer += delta

	if screen == "menu":
		update_map(delta)

	if toast_t > 0.0:
		toast_t -= delta

	if won and screen == "play":
		win_timer += delta
		reveal_t += delta
		if win_timer >= win_wait:
			win_timer = 0.0
			if current_level % AD_EVERY == 0:
				show_ad()
			else:
				finish_level_transition()

	queue_redraw()

# ---------------------------------------------------------------- boss levels

# every 10th level is a boss level
func is_boss(l: int) -> bool:
	return l % 10 == 0

# ---------------------------------------------------------------- ads

# PLACEHOLDER. Replace the body with your ad plugin's "show interstitial"
# call, and call finish_level_transition() from its "closed" and
# "failed to show" signals. If no ad is ready, call it immediately.
func show_ad():
	screen = "ad"
	ad_timer = 0.0

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

func settings_rect(i: int) -> Rect2:
	var extra: float = 34.0 if i >= 2 else 0.0
	return Rect2(40.0, 205.0 + float(i) * 104.0 + extra, 640.0, 90.0)

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
			open_link("mailto:" + SUPPORT_EMAIL + "?subject=Magic%20Sort%20support")

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
	# a new color every 5 levels (4 colors at level 5, 10 colors at level 35)
	var colors: int = clampi(3 + floori(float(l) / 5.0), 4, 10)
	var empty: int = 2
	if l >= 15 and l < 40:
		empty = 1 if l % 3 == 0 else 2
	elif l >= 40:
		empty = 2 if l % 4 == 0 else 1   # every 4th level is a "breather"
	# boss levels: one extra color and fewer empty bottles
	if is_boss(l):
		colors = clampi(colors + 1, 5, 10)
		empty = 1 if l >= 30 else 2
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

# 0..1: how mixed the bottles are (share of neighbouring layers with different colors)
func mix_score() -> float:
	var trans: int = 0
	var slots: int = 0
	for t in tubes:
		var arr: Array = t
		if arr.size() < 2:
			continue
		slots += arr.size() - 1
		for i in range(1, arr.size()):
			if arr[i] != arr[i - 1]:
				trans += 1
	return float(trans) / float(maxi(slots, 1))

# how mixed a level must be: rises steadily with the level number
func target_mix(l: int) -> float:
	var m: float = clampf(0.35 + float(l) * 0.005, 0.35, 0.80)
	if is_boss(l):
		m = minf(m + 0.05, 0.85)
	return m
	
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
	# every level gets its own color set (same every time the level is played)
	var palette: Array = []
	for i in COLORS.size():
		palette.append(i)
	var prng := RandomNumberGenerator.new()
	prng.seed = level * 7919 + 13
	for i in range(palette.size() - 1, 0, -1):
		var j: int = prng.randi_range(0, i)
		var tmp: int = palette[i]
		palette[i] = palette[j]
		palette[j] = tmp

	var need: float = target_mix(level)
	var best: Array = []
	var best_score: float = -1.0
	var attempts: int = 0
	while true:
		attempts += 1
		tubes.clear()
		for c in num_colors:
			var t: Array = []
			for k in CAPACITY:
				t.append(palette[c])
			tubes.append(t)
		for e in empty:
			tubes.append([])
		var steps: int = mini(60 + level * 6, 500) + num_colors * 20
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
		if check_win():
			continue
		var sc: float = mix_score()
		if sc > best_score:
			best_score = sc
			best = []
			for t2 in tubes:
				var arr2: Array = t2
				best.append(arr2.duplicate())
		if sc >= need or attempts >= 25:
			break
	tubes.clear()
	for t3 in best:
		var arr3: Array = t3
		tubes.append(arr3.duplicate())
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
	var top_y: float = 380.0 if rows == 1 else 200.0 + row * 380.0
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
	if screen == "ad":
		if ad_timer >= AD_TIME and ad_btn.has_point(pos):
			play_sfx("click")
			finish_level_transition()
		return

	if animating:
		return

	# ---- bottom tab bar
	if tab_visible():
		for ti in 2:
			if tab_hit_rect(ti).has_point(pos):
				if ti != tab_index():
					set_tab(ti)
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

func draw_ad():
	draw_rect(Rect2(0, 0, SCREEN_W, SCREEN_H), Color(0, 0, 0, 0.7))
	draw_style_box(btn_style(Color(0.18, 0.16, 0.45)), Rect2(60, 300, 600, 560))
	text_c("ADVERTISEMENT", 400.0, 48, Color(1.0, 0.9, 0.4))
	text_c("(placeholder - real ad goes here)", 470.0, 28, Color.WHITE)
	var left: int = ceili(AD_TIME - ad_timer)
	if left > 0:
		text_c("Continue in " + str(left), 790.0, 36, Color.WHITE)
	else:
		draw_button(ad_btn, "CONTINUE", 40, Color(0.2, 0.6, 0.3))

func draw_play():
	text_c("LEVEL " + str(current_level), 100.0, 52, Color.WHITE)
	if fill_kind == "sand":
		text_c("SAND LEVEL", 150.0, 28, Color(1.0, 0.82, 0.45))
	elif fill_kind == "gas":
		text_c("GAS LEVEL", 150.0, 28, Color(0.55, 0.95, 1.0))

	if not is_boss(current_level):
		var tier: String = "EASY"
		if current_level >= 60:
			tier = "EXPERT"
		elif current_level >= 30:
			tier = "HARD"
		elif current_level >= 10:
			tier = "MEDIUM"
		text_c(tier, 190.0, 24, Color(1, 1, 1, 0.6))
		
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
