extends Node2D


@export var hull_color: Color = Color(0.12, 0.16, 0.24)
@export var rim_color: Color = Color(0.2, 0.85, 1.0)
@export var accent_color: Color = Color(0.95, 0.8, 0.1)

var _flash_color: Color = Color.TRANSPARENT
var _flash_intensity: float = 0.0
var _anim_time: float = 0.0

func _process(delta: float) -> void:
	_anim_time += delta
	if _flash_intensity > 0.0:
		_flash_intensity = maxf(0.0, _flash_intensity - delta * 4.0)
		queue_redraw()
	else:
		# Periodic subtle redraw for thruster animations
		queue_redraw()

func flash(c: Color) -> void:
	_flash_color = c
	_flash_intensity = 1.0
	queue_redraw()

func _draw() -> void:
	# Width: ~120px, Height: ~45px
	var top_w: float = 65.0
	var bottom_w: float = 40.0
	var height: float = 38.0
	var top_y: float = -height * 0.5
	var bot_y: float = height * 0.5

	# Draw thruster flames if moving / active
	var player = get_parent()
	var is_boosting: bool = bool(player.get("is_boosting")) if player else false
	var vel_factor: float = clampf(absf(float(player.get("current_velocity"))) / 400.0, 0.2, 1.5) if player else 0.5

	# Thrusters positions
	var thruster_left = Vector2(-25.0, bot_y)
	var thruster_right = Vector2(25.0, bot_y)
	var flame_len = (18.0 if not is_boosting else 32.0) * vel_factor + sin(_anim_time * 25.0) * 4.0
	var flame_col = Color(0.2, 0.7, 1.0, 0.8) if not is_boosting else Color(1.0, 0.5, 0.1, 0.9)
	var flame_inner_col = Color(1.0, 1.0, 1.0, 0.9)

	# Left flame
	draw_colored_polygon(
		PackedVector2Array([
			thruster_left + Vector2(-8, 0),
			thruster_left + Vector2(8, 0),
			thruster_left + Vector2(0, flame_len)
		]),
		flame_col
	)
	draw_colored_polygon(
		PackedVector2Array([
			thruster_left + Vector2(-4, 0),
			thruster_left + Vector2(4, 0),
			thruster_left + Vector2(0, flame_len * 0.55)
		]),
		flame_inner_col
	)

	# Right flame
	draw_colored_polygon(
		PackedVector2Array([
			thruster_right + Vector2(-8, 0),
			thruster_right + Vector2(8, 0),
			thruster_right + Vector2(0, flame_len)
		]),
		flame_col
	)
	draw_colored_polygon(
		PackedVector2Array([
			thruster_right + Vector2(-4, 0),
			thruster_right + Vector2(4, 0),
			thruster_right + Vector2(0, flame_len * 0.55)
		]),
		flame_inner_col
	)

	# Main Hull Polygon
	var hull_pts = PackedVector2Array([
		Vector2(-top_w, top_y),
		Vector2(top_w, top_y),
		Vector2(bottom_w, bot_y),
		Vector2(-bottom_w, bot_y)
	])

	var current_hull_color = hull_color.lerp(_flash_color, _flash_intensity * 0.7)
	draw_colored_polygon(hull_pts, current_hull_color)

	# Hull outline
	var outline_color = Color(0.3, 0.45, 0.65)
	draw_polyline(
		PackedVector2Array([
			Vector2(-top_w, top_y),
			Vector2(-bottom_w, bot_y),
			Vector2(bottom_w, bot_y),
			Vector2(top_w, top_y)
		]),
		outline_color,
		2.5
	)

	# Catch Funnel / Energy Glow inside the basket
	var glow_alpha = 0.35 + 0.15 * sin(_anim_time * 6.0)
	var glow_color = rim_color
	glow_color.a = glow_alpha
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(-top_w + 8, top_y + 2),
			Vector2(top_w - 8, top_y + 2),
			Vector2(bottom_w - 8, bot_y - 8),
			Vector2(-bottom_w + 8, bot_y - 8)
		]),
		glow_color
	)

	# Glowing Catch Rim at top
	var current_rim_color = rim_color.lerp(_flash_color, _flash_intensity)
	draw_line(Vector2(-top_w - 4, top_y), Vector2(top_w + 4, top_y), current_rim_color, 5.0)

	# Left and Right bumper end-caps
	draw_circle(Vector2(-top_w - 4, top_y), 5.5, current_rim_color)
	draw_circle(Vector2(top_w + 4, top_y), 5.5, current_rim_color)

	# Center Energy Core
	var core_pulse = 0.5 + 0.5 * sin(_anim_time * 8.0)
	var core_color = accent_color.lerp(Color.WHITE, core_pulse * 0.4)
	draw_circle(Vector2(0, 0), 6.5, core_color)
	draw_arc(Vector2(0, 0), 9.0, 0, TAU, 16, current_rim_color, 2.0)

