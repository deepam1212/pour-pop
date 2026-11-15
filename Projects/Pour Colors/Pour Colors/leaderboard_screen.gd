class_name LeaderboardScreen
extends GameCore
# Leaderboard screen.


# leaderboard
var lb_names: Array = ["Luna", "Max", "Aria", "Zayn", "Mia", "Leo", "Nora", "Kabir", "Ivy", "Rohan",
	"Sofia", "Arjun", "Chloe", "Dev", "Emma", "Anaya", "Noah", "Riya"]

var lb_levels: Array = [100, 96, 91, 87, 83, 78, 72, 66, 61, 55, 49, 43, 36, 28, 20, 13, 8, 4]

var lb_entries: Array = []

func lb_unlocked() -> bool:
	return completed >= LB_UNLOCK_LEVEL

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
