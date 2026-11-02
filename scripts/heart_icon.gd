class_name HeartIcon
extends Control

@export var filled: bool = true

const FULL_COLOR := Color("#ff5a7a")
const EMPTY_COLOR := Color(1.0, 1.0, 1.0, 0.22)

func _ready() -> void:
	custom_minimum_size = Vector2(26, 24)
	queue_redraw()

func set_filled(value: bool) -> void:
	if filled == value:
		return
	filled = value
	queue_redraw()

func _draw() -> void:
	var color := FULL_COLOR if filled else EMPTY_COLOR
	var points := PackedVector2Array()
	var steps := 60
	for i in steps:
		var t := TAU * float(i) / float(steps)
		var s := sin(t)
		var x := 16.0 * s * s * s
		var y := 13.0 * cos(t) - 5.0 * cos(2.0 * t) - 2.0 * cos(3.0 * t) - cos(4.0 * t)
		points.append(Vector2(x, -y))

	var min_point := Vector2(INF, INF)
	var max_point := Vector2(-INF, -INF)
	for point in points:
		min_point = min_point.min(point)
		max_point = max_point.max(point)

	var span := max_point - min_point
	var heart_scale: float = minf(size.x / span.x, size.y / span.y) * 0.92
	var origin: Vector2 = (size - span * heart_scale) * 0.5 - min_point * heart_scale
	for i in points.size():
		points[i] = points[i] * heart_scale + origin

	draw_colored_polygon(points, color)
