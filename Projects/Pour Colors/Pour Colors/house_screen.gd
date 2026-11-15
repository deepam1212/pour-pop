class_name HouseScreen
extends HouseScreenFX
# =====================================================================
#  HOUSE SCREEN - UI LAYER
#
#  Architecture (three layers, each with one job):
#    HouseScreenBase  -> data, item art, saves        (unchanged)
#    HouseScreenFX    -> scene art, day/night, juice  (your old HouseScreen,
#                        only the first two lines renamed)
#    HouseScreen      -> THIS FILE: all UI chrome. Overrides the draw_* /
#                        hx_draw_* hooks, so the FX layer calls it for free.
#
#  Design system
#    - one palette (UI_*), one radius scale, one elevation helper
#    - ui_panel / ui_ring / ui_chip / ui_cta are the only widget primitives;
#      every screen element is composed from them
#    - everything animated is smoothed (rings, score count-up, card lift)
# =====================================================================

# ---------------------------------------------------------------- design tokens

const UI_SURFACE_TOP := Color(0.17, 0.20, 0.34)
const UI_SURFACE_BOT := Color(0.07, 0.08, 0.15)
const UI_BORDER := Color(1, 1, 1, 0.14)
const UI_TEXT := Color(1, 1, 1, 0.96)
const UI_TEXT_DIM := Color(1, 1, 1, 0.55)
const UI_ACCENT := Color(1.0, 0.82, 0.30)
const UI_ACCENT_DEEP := Color(1.0, 0.66, 0.16)
const UI_OK := Color(0.30, 0.80, 0.50)
const UI_ALERT := Color(1.0, 0.34, 0.34)
const UI_TAG_COLS := [Color(0.38, 0.62, 1.0), Color(0.30, 0.82, 0.60), Color(1.0, 0.50, 0.40)]
const UI_R_SM := 10.0
const UI_R_MD := 18.0
const UI_R_LG := 30.0

# ---------------------------------------------------------------- state

var ui_score_vis: float = 0.0
var ui_room_vis: Array = [0.0, 0.0, 0.0, 0.0, 0.0]

# ---------------------------------------------------------------- lifecycle

func hx_reset_fx():
	super.hx_reset_fx()
	ui_score_vis = 0.0
	ui_room_vis = [0.0, 0.0, 0.0, 0.0, 0.0]

func hx_update(dt: float):
	super.hx_update(dt)
	ui_score_vis = move_toward(ui_score_vis, float(house_done * 10), dt * 70.0)
	var stats: Array = hx_get_stats()
	for i in PANELS:
		var e: Array = stats[i]
		var f: float = float(e[0]) / float(maxi(1, int(e[1])))
		ui_room_vis[i] = lerpf(float(ui_room_vis[i]), f, 1.0 - exp(-6.0 * dt))

# ---------------------------------------------------------------- widget primitives

# elevated surface: soft stacked shadow, gradient body, top highlight, hairline border
func ui_panel(r: Rect2, rad: float, alpha: float = 0.96, elev: float = 1.0):
	for k in 3:
		var g: float = float(k + 1) * 2.0 * elev
		hx_rr(Rect2(r.position + Vector2(-g * 0.4, 3.0 + g * 0.8), r.size + Vector2(g * 0.8, 0.0)), rad + g, Color(0, 0, 0, 0.10), Color(0, 0, 0, 0.10))
	var top := Color(UI_SURFACE_TOP.r, UI_SURFACE_TOP.g, UI_SURFACE_TOP.b, alpha)
	var bot := Color(UI_SURFACE_BOT.r, UI_SURFACE_BOT.g, UI_SURFACE_BOT.b, alpha)
	hx_rr(r, rad, top, bot)
	hx_rr_line(r, rad, UI_BORDER, 1.5)
	draw_line(r.position + Vector2(rad, 1.5), Vector2(r.end.x - rad, r.position.y + 1.5), Color(1, 1, 1, 0.20), 1.5, true)

# circular progress, starts at 12 o'clock
func ui_ring(c: Vector2, rad: float, w: float, frac: float, col: Color, back: Color):
	draw_arc(c, rad, 0.0, TAU, 40, back, w, true)
	var f: float = clampf(frac, 0.0, 1.0)
	if f > 0.005:
		draw_arc(c, rad, -PI * 0.5, -PI * 0.5 + TAU * f, maxi(6, int(40.0 * f)), col, w, true)

func ui_chip(r: Rect2, label: String, size: int, fill: Color, ink: Color):
	hx_rr(r, r.size.y * 0.5, fill.lightened(0.15), fill.darkened(0.12))
	text_c(label, r.position.y + r.size.y * 0.5 + float(size) * 0.36, size, ink, r.position.x, r.size.x)

# primary call-to-action: depth, gloss, animated shine when enabled
func ui_cta(r: Rect2, label: String, size: int, base: Color, enabled: bool):
	var pulse: float = 0.5 + 0.5 * sin(time_acc * 4.0)
	var rect: Rect2 = r.grow(2.0 * pulse) if enabled else r
	hx_rr(Rect2(rect.position + Vector2(0.0, 6.0), rect.size), UI_R_MD, Color(0, 0, 0, 0.38), Color(0, 0, 0, 0.38))
	var top: Color = base.lightened(0.28) if enabled else Color(0.30, 0.32, 0.42)
	var bot: Color = base.darkened(0.18) if enabled else Color(0.17, 0.18, 0.27)
	hx_rr(rect, UI_R_MD, top, bot)
	hx_rr(Rect2(rect.position + Vector2(4.0, 3.0), Vector2(rect.size.x - 8.0, rect.size.y * 0.42)), UI_R_MD - 4.0, Color(1, 1, 1, 0.30 if enabled else 0.10), Color(1, 1, 1, 0.02))
	hx_rr_line(rect, UI_R_MD, Color(1, 1, 1, 0.30 if enabled else 0.10), 1.5)
	if enabled:
		var bx: float = rect.position.x - 60.0 + fposmod(time_acc * 0.7, 1.8) / 1.8 * (rect.size.x + 120.0)
		var lo: float = rect.position.x + 8.0
		var hi: float = rect.end.x - 8.0
		if bx + 30.0 > lo + 2.0 and bx - 20.0 < hi - 2.0:
			draw_colored_polygon(PackedVector2Array([
				Vector2(clampf(bx, lo, hi), rect.position.y + 4.0), Vector2(clampf(bx + 30.0, lo, hi), rect.position.y + 4.0),
				Vector2(clampf(bx + 10.0, lo, hi), rect.end.y - 4.0), Vector2(clampf(bx - 20.0, lo, hi), rect.end.y - 4.0)]), Color(1, 1, 1, 0.22))
	var ty: float = rect.position.y + rect.size.y * 0.5 + float(size) * 0.36
	var tcol: Color = Color.WHITE if enabled else Color(1, 1, 1, 0.55)
	text_c(label, ty + 2.0, size, Color(0, 0, 0, 0.35), rect.position.x, rect.size.x)
	text_c(label, ty, size, tcol, rect.position.x, rect.size.x)

# ---------------------------------------------------------------- HUD (top-left card + time-of-day dial)

func hx_draw_hud():
	var ri: int = hx_rank_index(house_done)
	var total: int = maxi(1, HOUSE_STEPS.size())
	var card := Rect2(14.0, 214.0, 270.0, 62.0)
	ui_panel(card, 22.0, 0.80, 0.8)
	var rc := Vector2(card.position.x + 34.0, card.position.y + 31.0)
	ui_ring(rc, 21.0, 5.0, hx_xp_vis, UI_ACCENT, Color(1, 1, 1, 0.14))
	hx_star(rc, 11.0, UI_ACCENT, time_acc * 0.4)
	text_l(HX_RANKS[ri], Vector2(card.position.x + 68.0, card.position.y + 28.0), 17, UI_TEXT)
	text_l(str(house_done) + " / " + str(total) + " jobs", Vector2(card.position.x + 68.0, card.position.y + 48.0), 13, UI_TEXT_DIM)
	draw_line(Vector2(card.position.x + 182.0, card.position.y + 12.0), Vector2(card.position.x + 182.0, card.position.y + 50.0), Color(1, 1, 1, 0.12), 1.5)
	text_c(str(roundi(ui_score_vis)), card.position.y + 33.0, 25, UI_ACCENT, card.position.x + 184.0, 80.0)
	text_c("STYLE", card.position.y + 50.0, 11, UI_TEXT_DIM, card.position.x + 184.0, 80.0)
	# time-of-day dial
	var tc: Vector2 = HX_TOD_C
	if hx_tod_mode != 0:
		draw_circle(tc, 33.0, Color(1.0, 0.82, 0.30, 0.28))
	draw_circle(tc + Vector2(0.0, 3.0), 28.0, Color(0, 0, 0, 0.32))
	draw_circle(tc, 27.0, Color(0.12, 0.14, 0.26, 0.92))
	draw_arc(tc, 27.0, 0.0, TAU, 32, Color(1, 1, 1, 0.26), 1.5, true)
	draw_arc(tc, 27.0, -PI * 0.5, -PI * 0.5 + TAU * hx_tod_phase, 32, Color(1.0, 0.82, 0.30, 0.8), 2.5, true)
	hx_draw_tod_icon(tc)
	text_c(HX_TOD_NAMES[hx_tod_mode], tc.y + 47.0, 11, UI_TEXT_DIM, tc.x - 40.0, 80.0)

# ---------------------------------------------------------------- room title card

func hx_draw_title():
	var t: float = time_acc - hx_title_t
	if t < 0.0 or t > 2.6:
		return
	var a: float = clampf(t / 0.35, 0.0, 1.0) * clampf((2.6 - t) / 0.6, 0.0, 1.0)
	var e: float = 1.0 - pow(1.0 - clampf(t / 0.5, 0.0, 1.0), 3.0)
	var cur: int = clampi(roundi(cam_x / PANEL_W), 0, PANELS - 1)
	var y: float = 330.0
	var dk := Color(0, 0, 0, 0.42 * a)
	var cl := Color(0, 0, 0, 0.0)
	hq(Vector2(0.0, y - 60.0), Vector2(360.0, y - 60.0), Vector2(360.0, y + 74.0), Vector2(0.0, y + 74.0), cl, dk, dk, cl)
	hq(Vector2(360.0, y - 60.0), Vector2(720.0, y - 60.0), Vector2(720.0, y + 74.0), Vector2(360.0, y + 74.0), dk, cl, cl, dk)
	var slide: float = (1.0 - e) * 26.0
	var stats: Array = hx_get_stats()
	var se: Array = stats[cur]
	text_c("ROOM " + str(cur + 1) + " OF " + str(PANELS), y - 26.0 + slide, 14, Color(1.0, 0.82, 0.30, a), 0.0, 720.0)
	text_c(HX_ROOM_TITLES[cur], y + 18.0 + slide + 2.0, 48, Color(0, 0, 0, 0.5 * a), 2.0, 720.0)
	text_c(HX_ROOM_TITLES[cur], y + 18.0 + slide, 48, Color(1, 1, 1, a), 0.0, 720.0)
	draw_line(Vector2(360.0 - 110.0 * e, y + 34.0), Vector2(360.0 + 110.0 * e, y + 34.0), Color(1.0, 0.82, 0.30, a), 3.0, true)
	var sub: String = str(HX_ROOM_TAGS[cur]) + "   -   " + str(se[0]) + "/" + str(se[1]) + " jobs"
	text_c(sub, y + 62.0 + slide, 20, Color(1, 1, 1, 0.85 * a), 0.0, 720.0)

# ---------------------------------------------------------------- bottom navigation (room tabs)

func draw_nav():
	var cur: int = clampi(roundi(cam_x / PANEL_W), 0, PANELS - 1)
	var tpanel: int = -1
	if house_pending():
		var st: Array = HOUSE_STEPS[house_done]
		tpanel = SLOT_PANEL[int(st[0])]
	var pulse: float = 0.5 + 0.5 * sin(time_acc * 5.0)
	var stats: Array = hx_get_stats()
	for i in PANELS:
		var r: Rect2 = pill_rect(i)
		var on: bool = i == cur
		var e: Array = stats[i]
		var comp: bool = int(e[1]) > 0 and int(e[0]) >= int(e[1])
		if on:
			for g in 3:
				hx_rr(r.grow(float(g + 1) * 3.0), 16.0 + float(g) * 3.0, Color(1.0, 0.82, 0.30, 0.08), Color(1.0, 0.82, 0.30, 0.08))
			hx_rr(r, 15.0, Color(1.0, 0.90, 0.46, 0.98), Color(1.0, 0.70, 0.20, 0.98))
			hx_rr(Rect2(r.position + Vector2(3.0, 2.0), Vector2(r.size.x - 6.0, r.size.y * 0.4)), 12.0, Color(1, 1, 1, 0.35), Color(1, 1, 1, 0.02))
		else:
			hx_rr(r, 15.0, Color(0.14, 0.16, 0.27, 0.86), Color(0.05, 0.06, 0.12, 0.86))
			hx_rr_line(r, 15.0, UI_BORDER, 1.2)
		if i == tpanel and not on:
			hx_rr_line(r.grow(1.0 + 2.0 * pulse), 16.0, Color(1.0, 0.9, 0.4, 0.45 + 0.5 * pulse), 3.0)
			draw_circle(r.position + Vector2(r.size.x - 8.0, 6.0), 5.0 + pulse, UI_ALERT)
		var tcol: Color = Color(0.15, 0.10, 0.02) if on else Color.WHITE
		var tx: float = r.position.x
		var tw: float = r.size.x
		if comp:
			# completed room: green check on the left of the label
			var ck := Vector2(r.position.x + 15.0, r.position.y + 15.0)
			draw_circle(ck, 7.0, UI_OK)
			draw_polyline(PackedVector2Array([ck + Vector2(-3.0, 0.0), ck + Vector2(-0.8, 2.6), ck + Vector2(3.4, -2.6)]), Color.WHITE, 2.0, true)
			tx += 12.0
			tw -= 12.0
		text_c(PANEL_NAMES[i], r.position.y + 20.0, 16, tcol, tx, tw)
		var br := Rect2(r.position.x + 18.0, r.end.y - 7.0, r.size.x - 36.0, 3.0)
		hx_rr(br, 1.5, Color(0, 0, 0, 0.25) if on else Color(1, 1, 1, 0.16), Color(0, 0, 0, 0.25) if on else Color(1, 1, 1, 0.16))
		var fv: float = float(ui_room_vis[i])
		if fv > 0.01:
			var fc: Color = UI_OK if comp else (Color(0.40, 0.25, 0.02) if on else UI_ACCENT)
			hx_rr(Rect2(br.position, Vector2(maxf(3.0, br.size.x * fv), br.size.y)), 1.5, fc, fc)
	if tpanel >= 0 and tpanel != cur:
		var dir: float = 1.0 if tpanel > cur else -1.0
		var bx: float = 628.0 if dir > 0.0 else 12.0
		var off: float = sin(time_acc * 6.0) * 5.0 * dir
		var bd := Rect2(bx + off, 440.0, 80.0, 62.0)
		ui_panel(bd, 18.0, 0.0, 0.5)
		hx_rr(bd, 18.0, Color(1.0, 0.90, 0.44, 0.98), Color(1.0, 0.70, 0.18, 0.98))
		var cxm: float = bd.get_center().x
		for k in 2:
			var ox: float = cxm + dir * (float(k) * 11.0 - 6.0)
			draw_polyline(PackedVector2Array([Vector2(ox - dir * 6.0, 451.0), Vector2(ox + dir * 6.0, 465.0), Vector2(ox - dir * 6.0, 479.0)]), HX_INK, 5.0, true)
		text_c("JOB", 496.0, 13, HX_INK, bd.position.x, bd.size.x)
	else:
		var ca: float = 0.55 + 0.35 * sin(time_acc * 3.0)
		if cur < PANELS - 1:
			draw_polyline(PackedVector2Array([Vector2(690.0, 450.0), Vector2(706.0, 470.0), Vector2(690.0, 490.0)]), Color(1, 1, 1, ca), 5.0, true)
		if cur > 0:
			draw_polyline(PackedVector2Array([Vector2(30.0, 450.0), Vector2(14.0, 470.0), Vector2(30.0, 490.0)]), Color(1, 1, 1, ca), 5.0, true)
	if house_hint:
		var hint: String = "DRAG TO WALK THROUGH THE HOUSE"
		if hx_scrub_ready():
			hint = "SWIPE THE SCENE TO CLEAN IT"
		text_c(hint, 756.0, 20, Color(1, 1, 1, 0.5 + 0.4 * sin(time_acc * 3.0)), 0.0, 720.0)

# ---------------------------------------------------------------- bottom sheet

func draw_house_panel():
	hq(Vector2(0.0, 740.0), Vector2(720.0, 740.0), Vector2(720.0, 782.0), Vector2(0.0, 782.0), Color(0, 0, 0, 0.0), Color(0, 0, 0, 0.0), Color(0, 0, 0, 0.40), Color(0, 0, 0, 0.40))
	var sr := Rect2(24.0, 780.0, 672.0, 338.0)
	ui_panel(sr, UI_R_LG, 0.985, 1.6)
	_draw_job_track()
	hx_draw_alex_row()
	if house_pending():
		var st: Array = HOUSE_STEPS[house_done]
		var item: String = st[1]
		if item == "clean":
			hx_draw_clean_ui(int(st[0]))
		else:
			hx_draw_cards(item)
			if house_sel >= 0:
				ui_cta(house_place_rect, "PLACE IT", 30, Color(0.22, 0.72, 0.42), true)
			else:
				ui_cta(house_place_rect, "PICK AN OPTION", 25, Color(0.4, 0.4, 0.5), false)
	else:
		hx_draw_next_ui()

# segmented progress track across the sheet header: one segment per job
func _draw_job_track():
	var n: int = maxi(1, HOUSE_STEPS.size())
	var x0: float = 60.0
	var wtot: float = 600.0
	var gap: float = 3.0
	var sw: float = (wtot - gap * float(n - 1)) / float(n)
	var pulse: float = 0.5 + 0.5 * sin(time_acc * 5.0)
	for i in n:
		var seg := Rect2(x0 + float(i) * (sw + gap), 788.0, sw, 5.0)
		var col: Color = Color(1, 1, 1, 0.14)
		if i < house_done:
			col = UI_ACCENT
		elif i == house_done:
			col = Color(1.0, 0.95, 0.7, 0.35 + 0.5 * pulse)
		hx_rr(seg, 2.5, col, col)

func hx_draw_cards(item: String):
	var labels: Array = ITEM_LABELS.get(item, ["A", "B", "C"])
	for i in 3:
		var r: Rect2 = house_card_rect(i)
		var pop: float = float(hx_card_pop[i])
		var sel: bool = i == house_sel
		var s: float = 1.0 + 0.06 * pop
		var cc: Vector2 = r.get_center()
		draw_set_transform(Vector2(cc.x * (1.0 - s), cc.y * (1.0 - s) - 6.0 * pop), 0.0, Vector2(s, s))
		if pop > 0.02:
			for g in 4:
				hx_rr(r.grow(float(g + 1) * 3.5), 22.0 + float(g) * 2.0, Color(1.0, 0.85, 0.30, 0.09 * pop), Color(1.0, 0.85, 0.30, 0.09 * pop))
		hx_rr(Rect2(r.position + Vector2(0.0, 5.0), r.size), 18.0, Color(0, 0, 0, 0.30), Color(0, 0, 0, 0.30))
		hx_rr(r, 18.0, Color(0.26, 0.30, 0.48, 0.98) if sel else Color(0.16, 0.19, 0.31, 0.98), Color(0.12, 0.14, 0.25, 0.98) if sel else Color(0.08, 0.09, 0.17, 0.98))
		draw_thumb(item, i, r)
		# legibility band under the label
		var band := Rect2(r.position.x + 2.0, r.end.y - 34.0, r.size.x - 4.0, 32.0)
		hx_rr(band, 14.0, Color(0.04, 0.05, 0.10, 0.0), Color(0.04, 0.05, 0.10, 0.88))
		hx_rr_line(r, 18.0, UI_ACCENT if sel else UI_BORDER, 3.0 if sel else 1.5)
		text_c(str(labels[i]), r.end.y - 12.0, 19, Color.WHITE, r.position.x, r.size.x)
		var tag_col: Color = UI_TAG_COLS[i]
		ui_chip(Rect2(r.position.x + 12.0, r.position.y + 12.0, 64.0, 18.0), str(HX_OPTION_TAGS[i]), 11, tag_col, Color.WHITE)
		if sel:
			var bc := Vector2(r.end.x - 22.0, r.position.y + 22.0)
			draw_circle(bc, 13.0, UI_ACCENT)
			draw_polyline(PackedVector2Array([bc + Vector2(-5.0, 0.0), bc + Vector2(-1.5, 4.0), bc + Vector2(5.5, -4.0)]), HX_INK, 3.0, true)
		draw_set_transform(hx_shake, 0.0, Vector2.ONE)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func hx_draw_clean_ui(slot: int):
	var tc := Vector2(104.0, 996.0)
	var vis: float = clampf(hx_scrub_vis, 0.0, 1.0)
	draw_circle(tc, 62.0, Color(1, 1, 1, 0.05))
	ui_ring(tc, 58.0, 7.0, vis, Color(0.45, 0.95, 0.62), Color(1, 1, 1, 0.12))
	hx_draw_tool(tc + Vector2(0.0, 8.0), 1.4, slot)
	var verb: String = "MOWING" if slot == 5 else "CLEANING"
	text_l(verb, Vector2(190.0, 958.0), 16, UI_TEXT_DIM)
	var pr := Rect2(190.0, 968.0, 270.0, 28.0)
	hx_rr(pr, 14.0, Color(0, 0, 0, 0.40), Color(0, 0, 0, 0.40))
	if vis > 0.01:
		hx_rr(Rect2(pr.position, Vector2(maxf(28.0, pr.size.x * vis), pr.size.y)), 14.0, Color(0.55, 0.95, 0.65), Color(0.20, 0.72, 0.42))
		hx_rr(Rect2(pr.position + Vector2(3.0, 2.0), Vector2(maxf(22.0, (pr.size.x - 6.0) * vis), 8.0)), 6.0, Color(1, 1, 1, 0.30), Color(1, 1, 1, 0.02))
	hx_rr_line(pr, 14.0, UI_BORDER, 1.5)
	text_c(str(int(vis * 100.0)) + "%", pr.position.y + 21.0, 17, Color.WHITE, pr.position.x, pr.size.x)
	text_l("Swipe the scene to wipe the dirt away", Vector2(190.0, 1030.0), 17, Color(1, 1, 1, 0.65))
	ui_cta(hx_clean_rect, "AUTO CLEAN", 24, Color(0.20, 0.70, 0.42), not hx_autoclean)

func hx_draw_next_ui():
	if house_done < HOUSE_STEPS.size():
		var nx: Array = HOUSE_STEPS[house_done]
		var ir := Rect2(50.0, 906.0, 200.0, 146.0)
		ui_panel(ir, UI_R_MD, 0.98, 0.6)
		draw_step_icon(nx, ir)
		hx_rr(Rect2(ir.position + Vector2(10.0, 8.0), Vector2(ir.size.x - 20.0, 94.0)), UI_R_SM, Color(0.03, 0.04, 0.08, 0.55), Color(0.03, 0.04, 0.08, 0.55))
		hx_draw_lock(Vector2(ir.get_center().x, ir.position.y + 55.0), 1.0)
		text_c("LOCKED", ir.position.y + 131.0, 18, UI_TEXT_DIM, ir.position.x, ir.size.x)
		text_l("NEXT JOB", Vector2(282.0, 940.0), 15, UI_ACCENT)
		text_l(str(nx[2]), Vector2(282.0, 982.0), 26, Color.WHITE)
		var chip := Rect2(282.0, 1002.0, 250.0, 38.0)
		hx_rr(chip, 19.0, Color(1.0, 0.82, 0.30, 0.20), Color(1.0, 0.82, 0.30, 0.08))
		hx_rr_line(chip, 19.0, Color(1.0, 0.82, 0.30, 0.6), 1.5)
		text_c("CLEAR LEVEL " + str(house_done + 1), chip.position.y + 26.0, 19, UI_ACCENT, chip.position.x, chip.size.x)
		text_l("to unlock it", Vector2(282.0, 1068.0), 17, Color(1, 1, 1, 0.5))
	else:
		hx_star(Vector2(360.0, 950.0), 52.0, UI_ACCENT, sin(time_acc) * 0.2)
		text_c("HOUSE COMPLETE!", 1050.0, 38, UI_ACCENT, 30.0, 660.0)
		text_c("Your dream home is finished", 1084.0, 18, UI_TEXT_DIM, 30.0, 660.0)

# ---------------------------------------------------------------- unlock popup

func draw_unlock_card():
	if win_new_part < 0 or win_new_part >= HOUSE_STEPS.size():
		return
	var st: Array = HOUSE_STEPS[win_new_part]
	var card := Rect2(110.0, 330.0, 500.0, 430.0)
	var pulse: float = 0.5 + 0.5 * sin(time_acc * 4.0)
	ui_panel(card, 36.0, 0.99, 2.2)
	hx_rr_line(card, 36.0, Color(1.0, 0.82, 0.30, 0.55 + 0.3 * pulse), 3.0)
	var ic := Vector2(360.0, 543.0)
	for k in 14:
		var a: float = time_acc * 0.3 + float(k) / 14.0 * TAU
		var d0 := Vector2(cos(a - 0.08), sin(a - 0.08))
		var d1 := Vector2(cos(a + 0.08), sin(a + 0.08))
		draw_colored_polygon(PackedVector2Array([ic, ic + d0 * 190.0, ic + d1 * 190.0]), Color(1.0, 0.85, 0.35, 0.08))
	for k in 5:
		draw_circle(ic, 150.0 - float(k) * 26.0, Color(1.0, 0.85, 0.35, 0.05))
	var bn := Rect2(card.position.x + 60.0, card.position.y - 24.0, 380.0, 58.0)
	ui_cta(bn, "NEW HOUSE JOB!", 30, UI_ACCENT_DEEP, false)
	hx_rr(bn, 20.0, Color(1.0, 0.90, 0.44), Color(1.0, 0.70, 0.18))
	hx_rr(Rect2(bn.position + Vector2(4.0, 3.0), Vector2(bn.size.x - 8.0, 20.0)), 14.0, Color(1, 1, 1, 0.35), Color(1, 1, 1, 0.02))
	text_c("NEW HOUSE JOB!", bn.position.y + 40.0, 32, HX_INK, bn.position.x, bn.size.x)
	text_c(str(st[2]), 412.0, 28, Color.WHITE, card.position.x, card.size.x)
	hx_rr(Rect2(236.0, 456.0, 248.0, 174.0), 24.0, Color(1, 1, 1, 0.10), Color(1, 1, 1, 0.04))
	draw_step_icon(st, Rect2(250.0, 470.0, 220.0, 146.0))
	for k in 6:
		var sa: float = time_acc * 0.8 + float(k) * 1.05
		var sp: Vector2 = ic + Vector2(cos(sa), sin(sa)) * (130.0 + 14.0 * sin(time_acc * 2.0 + float(k)))
		draw_sparkle(sp, 8.0 + 4.0 * sin(time_acc * 3.0 + float(k)), Color(1.0, 1.0, 0.8, 0.8))
	ui_chip(Rect2(card.position.x + 70.0, 654.0, 360.0, 46.0), "Open the House tab to do it", 22, Color(0.30, 0.34, 0.54), Color(1, 1, 1, 0.95))
	if current_level == LB_UNLOCK_LEVEL:
		ui_chip(Rect2(card.position.x + 50.0, 712.0, 400.0, 40.0), "LEADERBOARD UNLOCKED!", 22, UI_OK, Color.WHITE)
