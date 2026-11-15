class_name SettingsScreen
extends LeaderboardScreen
# Settings screen + legal text pages.


# links used by the settings screen. Leave a URL empty "" to show the
# built-in text page instead (privacy / terms) or to do nothing (rate).
const PRIVACY_URL = ""

const TERMS_URL = ""

const RATE_URL = ""

const SUPPORT_EMAIL = "deepamsharma668@gmail.com"

const APP_VERSION = "1.0.0"

# built-in text pages.
const DOC_PRIVACY = "Last updated: October 30, 2026\n\nPour Pop does not collect, store or share any personal information.\n\nThe game has no accounts, no ads, no in-app purchases and no analytics or tracking tools.\n\nYour game progress and settings are saved only on your device. They are never sent to us or to any third party. Deleting the app removes this data.\n\nWe do not sell personal data or share it with third parties.\n\nPour Pop does not collect personal information from anyone, including children under 13.\n\nIf our practices change, we will update this policy.\n\nQuestions? Contact Deepam Sharma at deepamsharma668@gmail.com"

const DOC_TERMS = "Last updated: October 30, 2026\n\nBy installing or playing Pour Pop you agree to these terms.\n\n1. License: Deepam Sharma grants you a personal, non-exclusive, non-transferable license to use the game for your own non-commercial entertainment.\n\n2. You may not copy, modify, sell, redistribute or reverse engineer the game, or use it for any unlawful purpose.\n\n3. Your progress and settings are stored only on your device. Deleting the app removes them.\n\n4. The game is provided \"as is\" without warranties. To the extent permitted by law, we are not liable for indirect or consequential losses, loss of progress, or problems caused by your device.\n\n5. We may update these terms or the game at any time. Continuing to play means you accept the changes.\n\nContact: deepamsharma668@gmail.com"

const DOC_ABOUT = "Pour Pop is a relaxing color-sorting puzzle.\n\nPour liquids, sand and gas between the bottles until every bottle holds just one color.\n\n100 levels are waiting for you, from easy to tricky.\n\nThank you for playing!"

var doc_kind: String = ""

var doc_lines: Array = []

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
				if tts_ok:
					DisplayServer.tts_stop()
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
			open_link("mailto:" + SUPPORT_EMAIL + "?subject=Pour%20Pop%20support")

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
	text_c("Pour Colors  v" + APP_VERSION, 1070.0, 22, Color(1, 1, 1, 0.45))

func draw_doc():
	var titles: Dictionary = {"privacy": "PRIVACY POLICY", "terms": "TERMS & CONDITIONS", "about": "ABOUT"}
	var title: String = titles.get(doc_kind, "INFO")
	text_c(title, 100.0, 44, Color(1.0, 0.9, 0.4), 130.0, 560.0)
	draw_icon_button(menu_rect, "back", Color(0.35, 0.45, 0.95))
	draw_style_box(card_style, Rect2(40.0, 175.0, 640.0, 1010.0))
	var font: Font = ThemeDB.fallback_font
	for li in doc_lines.size():
		var ln: String = doc_lines[li]
		draw_string(font, Vector2(75.0, 232.0 + float(li) * 36.0), ln,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color(1, 1, 1, 0.92))
