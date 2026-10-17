class_name FallingWord
extends Area2D

signal word_caught(is_correct: bool, text: String, pos: Vector2)
signal word_missed(is_correct: bool, text: String)

@export var base_speed: float = 160.0
@export var speed_variance: float = 25.0

var word_text: String = ""
var is_correct: bool = false
var fall_speed: float = 160.0
var drift_frequency: float = 2.0
var drift_amplitude: float = 20.0
var base_x: float = 0.0
var _time_alive: float = 0.0
var is_caught: bool = false
var is_poofing: bool = false

@onready var panel: PanelContainer = $PanelContainer
@onready var label: Label = $PanelContainer/MarginContainer/Label
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var particles: CPUParticles2D = $CPUParticles2D

func _ready() -> void:
	add_to_group("falling_words")
	fall_speed = base_speed + randf_range(-speed_variance, speed_variance)
	drift_frequency = randf_range(1.5, 2.5)
	drift_amplitude = randf_range(12.0, 24.0)
	base_x = position.x
	_update_visuals()

func setup(p_text: String, p_is_correct: bool, p_speed_mult: float = 1.0) -> void:
	word_text = p_text
	is_correct = p_is_correct
	fall_speed = (base_speed + randf_range(-15.0, 25.0)) * p_speed_mult
	if is_node_ready():
		_update_visuals()

func _update_visuals() -> void:
	if label:
		label.text = word_text
	# Defer updating collision shape so layout has settled
	call_deferred("_update_collision_size")

func _update_collision_size() -> void:
	if not is_inside_tree() or not panel or not collision_shape:
		return
	var min_sz = panel.get_minimum_size()
	var w = maxf(min_sz.x, 80.0)
	var h = maxf(min_sz.y, 40.0)

	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(w + 10.0, h + 8.0)
	collision_shape.shape = rect_shape

func _physics_process(delta: float) -> void:
	if is_caught or is_poofing:
		return

	_time_alive += delta
	# Horizontal gentle wave drift
	position.x = base_x + sin(_time_alive * drift_frequency) * drift_amplitude
	# Downward fall
	position.y += fall_speed * delta

	# Tilting
	rotation = cos(_time_alive * drift_frequency) * 0.06

	# Screen bounds check (falling off the bottom)
	# Bottom question bar is around Y = 568..648, so if it reaches ~650 it missed
	if position.y > 640.0:
		_on_fallen_off_screen()

func catch_by_player() -> void:
	if is_caught or is_poofing:
		return
	is_caught = true

	# Disable collision
	collision_shape.set_deferred("disabled", true)
	word_caught.emit(is_correct, word_text, global_position)
	
	# Trigger particle burst
	if particles:
		particles.color = Color(0.2, 1.0, 0.4) if is_correct else Color(1.0, 0.3, 0.3)
		particles.emitting = true

	# Pop animation
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.35, 1.35), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(self, "scale", Vector2(0.1, 0.1), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate:a", 0.0, 0.25)
	tween.chain().tween_callback(queue_free)

func poof_away() -> void:
	if is_caught or is_poofing:
		return
	is_poofing = true
	collision_shape.set_deferred("disabled", true)

	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(0.2, 0.2), 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.chain().tween_callback(queue_free)

func _on_fallen_off_screen() -> void:
	if is_caught or is_poofing:
		return
	is_caught = true
	word_missed.emit(is_correct, word_text)
	queue_free()

