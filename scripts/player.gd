class_name PlayerCatcher
extends Area2D

signal word_caught(word_node: Area2D)

@export var move_speed: float = 520.0
@export var boost_speed: float = 880.0
@export var acceleration: float = 24.0
@export var friction: float = 18.0

var current_velocity: float = 0.0
var screen_min_x: float = 65.0
var screen_max_x: float = 1087.0

var is_boosting: bool = false
var original_scale: Vector2 = Vector2.ONE
#var _thruster_time: float = 0.0
var mouse_control_active: bool = false

@onready var visual_node: Node2D = $Visual
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	add_to_group("player")
	original_scale = scale
	area_entered.connect(_on_area_entered)
	_update_screen_bounds()
	get_viewport().size_changed.connect(_update_screen_bounds)

func _update_screen_bounds() -> void:
	var viewport_size = get_viewport_rect().size
	screen_min_x = 65.0
	screen_max_x = maxf(screen_min_x + 100.0, viewport_size.x - 65.0)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# If mouse moved significantly, allow mouse steering
		var mouse_event = event as InputEventMouseMotion
		if absf(mouse_event.relative.x) > 2.0:
			mouse_control_active = true
	elif event is InputEventKey:
		# If arrow or WASD keys pressed, keyboard takes priority
		if event.is_action_pressed("move_left") or event.is_action_pressed("move_right") or \
		   event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right") or \
		   event.keycode == KEY_A or event.keycode == KEY_D:
			mouse_control_active = false

func _physics_process(delta: float) -> void:
	var input_dir: float = 0.0

	# Keyboard / controller inputs
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		input_dir -= 1.0
	if Input.is_action_pressed("move_right") or Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		input_dir += 1.0

	is_boosting = Input.is_action_pressed("speed_boost") or Input.is_key_pressed(KEY_SHIFT) or Input.is_key_pressed(KEY_SPACE)

	# If mouse control is active and no keyboard key is actively held
	if mouse_control_active and is_zero_approx(input_dir):
		var target_x: float = clampf(get_global_mouse_position().x, screen_min_x, screen_max_x)
		var diff: float = target_x - global_position.x
		if absf(diff) > 4.0:
			input_dir = clampf(diff / 40.0, -1.0, 1.0)
		else:
			input_dir = 0.0

	var target_speed: float = (boost_speed if is_boosting else move_speed) * input_dir
	if not is_zero_approx(input_dir):
		current_velocity = lerpf(current_velocity, target_speed, acceleration * delta)
	else:
		current_velocity = lerpf(current_velocity, 0.0, friction * delta)

	global_position.x += current_velocity * delta
	global_position.x = clampf(global_position.x, screen_min_x, screen_max_x)

	# Slight banking / tilt when moving fast
	var tilt_angle = (current_velocity / move_speed) * 0.12
	if visual_node:
		visual_node.rotation = lerpf(visual_node.rotation, tilt_angle, 15.0 * delta)
		visual_node.queue_redraw()

func trigger_catch_animation(is_correct: bool) -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# Squash horizontally and stretch vertically or vice-versa
	tween.tween_property(visual_node, "scale", Vector2(1.28, 0.72), 0.08)
	tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(visual_node, "scale", Vector2.ONE, 0.25)

	# Visual flash
	if visual_node.has_method("flash"):
		visual_node.flash(Color(0.2, 1.0, 0.4) if is_correct else Color(1.0, 0.25, 0.25))

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("falling_words"):
		word_caught.emit(area)

