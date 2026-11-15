class_name GameTabBar
extends StoryScreen
# Bottom tab bar + tab navigation.
# Tabs: Story (index 1) and Settings (index 3).

# bottom tab bar
const TAB_IDS := [1, 3]                       # story, settings
const TAB_COLORS := [
	Color(0.20, 0.85, 0.80),   # story
	Color(0.40, 0.55, 1.00),   # settings
]
const TAB_LABELS := ["Story", "Settings"]

const TAB_W := 200.0                          # width of each tab
const TAB_BAR_W := TAB_W * 2.0                # total bar width = 400
const SCREEN_W := 720.0

# centered bar: x = (720 - 400) / 2 = 160
var tab_rect := Rect2((SCREEN_W - TAB_BAR_W) * 0.5, 1128, TAB_BAR_W, 124)

# ---------------------------------------------------------------- tab bar / navigation

# the tab bar is shown on the story map and settings
func tab_visible() -> bool:
	if screen == "settings":
		return true
	return screen == "menu" and hop_state == "none"

# which tab (1 = story, 3 = settings) the current screen belongs to
func tab_index() -> int:
	match screen:
		"settings", "doc":
			return 3
	return 1

# position of a tab on the bar: story = left slot, settings = right slot
func tab_slot(i: int) -> int:
	match i:
		1:
			return 0
		3:
			return 1
	return -1

func tab_hit_rect(i: int) -> Rect2:
	var slot: int = tab_slot(i)
	if slot < 0:
		return Rect2()   # not a tab: empty rect, never hit
	return Rect2(tab_rect.position.x + float(slot) * TAB_W, tab_rect.position.y - 34.0, TAB_W, tab_rect.size.y + 34.0)

func set_tab(i: int):
	welcome_shown = true
	match i:
		1:
			play_sfx("click")
			if screen != "menu":
				go_menu()
		3:
			play_sfx("click")
			open_settings()

# ---------------------------------------------------------------- bottom tab bar

func draw_tab_icon(i: int, c: Vector2, s: float, col: Color, hole: Color):
	var h: float = s * 0.5
	match i:
		1:
			# map pin (story)
			var pc: Vector2 = c + Vector2(0.0, -0.3 * h)
			draw_colored_polygon(PackedVector2Array([
				pc + Vector2(-0.62 * h, 0.25 * h), pc + Vector2(0.62 * h, 0.25 * h),
				c + Vector2(0.0, 1.05 * h)]), col)
			draw_circle(pc, 0.7 * h, col)
			draw_circle(pc, 0.28 * h, hole)
		3:
			# gear (settings)
			for k in 8:
				var a: float = float(k) / 8.0 * TAU
				var d := Vector2(cos(a), sin(a))
				draw_line(c + d * 0.55 * h, c + d * 1.02 * h, col, 0.42 * h, true)
			draw_circle(c, 0.75 * h, col)
			draw_circle(c, 0.3 * h, hole)


func draw_tab_bar():
	var bar: Rect2 = tab_rect

	draw_style_box(tab_style, bar)

	# pv: 0.0 = story selected, 1.0 = settings selected (tab_pos runs 1..3)
	var pv: float = clampf((tab_pos - 1.0) / 2.0, 0.0, 1.0)
	var bub_col: Color = TAB_COLORS[0].lerp(TAB_COLORS[1], pv)
	var bcx: float = bar.position.x + TAB_W * (pv + 0.5)
	var bcy: float = bar.position.y + 22.0

	for k in 5:
		draw_circle(
			Vector2(bcx, bcy + 6.0),
			78.0 - float(k) * 9.0,
			Color(bub_col.r, bub_col.g, bub_col.b, 0.06)
		)

	draw_circle(Vector2(bcx, bcy), 60.0, TAB_BAR_COL)
	draw_circle(Vector2(bcx, bcy), 52.0, bub_col.darkened(0.3))
	draw_circle(Vector2(bcx, bcy - 2.0), 49.0, bub_col)
	draw_circle(Vector2(bcx - 15.0, bcy - 20.0), 17.0, Color(1, 1, 1, 0.28))
	draw_arc(Vector2(bcx, bcy), 52.0, 0.0, TAU, 40, Color(1, 1, 1, 0.55), 3.0, true)

	var tw1: float = 0.5 + 0.5 * sin(time_acc * 3.0)
	var tw2: float = 0.5 + 0.5 * sin(time_acc * 3.0 + 2.0)
	draw_sparkle(Vector2(bcx + 46.0, bcy - 40.0), 4.0 + 5.0 * tw1, Color(1, 1, 1, 0.5 + 0.5 * tw1))
	draw_sparkle(Vector2(bcx - 52.0, bcy - 26.0), 3.0 + 4.0 * tw2, Color(1, 1, 1, 0.4 + 0.5 * tw2))

	# Story (slot 0) and Settings (slot 1)
	for slot in 2:
		var i: int = TAB_IDS[slot]
		var a: float = clampf(1.0 - absf(pv - float(slot)), 0.0, 1.0)
		var cx: float = bar.position.x + TAB_W * (float(slot) + 0.5)
		var cy: float = lerpf(bar.position.y + 52.0, bcy, a)
		var isz: float = lerpf(40.0, 46.0, a)
		var icol := Color(1, 1, 1, lerpf(0.55, 1.0, a))
		var hole: Color = TAB_BAR_COL.lerp(bub_col, a)

		draw_tab_icon(i, Vector2(cx, cy), isz, icol, hole)

		var lcol := Color(1, 1, 1, lerpf(0.55, 1.0, a))
		text_c(TAB_LABELS[slot], bar.end.y - 16.0, 20, lcol, cx - TAB_W / 2.0, TAB_W)
