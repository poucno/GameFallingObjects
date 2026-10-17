class_name MainGame
extends Node2D

const QuestionDatabaseScript = preload("res://scripts/question_database.gd")
const FallingWordScript = preload("res://scripts/falling_word.gd")

@export var falling_word_scene: PackedScene = preload("res://scenes/falling_word.tscn")

var database: RefCounted
var current_question: Dictionary = {}
var question_index: int = 0
var questions_solved: int = 0

var score: int = 0
var high_score: int = 0
var lives: int = 3
const MAX_LIVES: int = 3
var streak: int = 0

var is_game_over: bool = false
var is_wave_active: bool = false
var active_words: Array[Area2D] = []
var pending_spawns: Array[Dictionary] = []
var spawn_timer: float = 0.0

# Camera shake
var shake_intensity: float = 0.0
@onready var camera: Camera2D = $Camera2D
@onready var player: Node2D = $Player
@onready var hud: CanvasLayer = $HUD
@onready var words_container: Node2D = $WordsContainer

const SAVE_PATH: String = "user://word_catcher_save.cfg"

func _ready() -> void:
	randomize()
	database = QuestionDatabaseScript.new()
	_load_high_score()

	if hud:
		hud.restart_requested.connect(_on_restart_requested)
		hud.resume_requested.connect(_on_resume_requested)
	if player:
		player.word_caught.connect(_on_player_word_caught)

	start_new_game()

func _load_high_score() -> void:
	var cfg = ConfigFile.new()
	var err = cfg.load(SAVE_PATH)
	if err == OK:
		high_score = cfg.get_value("game", "high_score", 0)
	else:
		high_score = 0
	if hud and hud.has_method("update_high_score"):
		hud.update_high_score(high_score)

func _save_high_score() -> void:
	var cfg = ConfigFile.new()
	cfg.set_value("game", "high_score", high_score)
	cfg.save(SAVE_PATH)

func _play_sound(method_name: String) -> void:
	if has_node("/root/SoundManager"):
		var sm = get_node("/root/SoundManager")
		if sm and sm.has_method(method_name):
			sm.call(method_name)

func start_new_game() -> void:
	is_game_over = false
	if get_tree():
		get_tree().paused = false
	score = 0
	lives = MAX_LIVES
	streak = 0
	question_index = 0
	questions_solved = 0

	if hud:
		hud.hide_game_over()
		hud.set_pause_visible(false)
		hud.update_score(score)
		hud.update_high_score(high_score)
		hud.update_lives(lives, MAX_LIVES)
		hud.update_streak(streak)

	if database:
		database.reset()
	_clear_all_words()
	_load_next_question()

func _clear_all_words() -> void:
	pending_spawns.clear()
	for word in active_words:
		if is_instance_valid(word):
			word.queue_free()
	active_words.clear()

func _load_next_question() -> void:
	if is_game_over:
		return

	# Remove any remaining distractors from last round
	for word in active_words:
		if is_instance_valid(word) and word.has_method("poof_away"):
			word.poof_away()
	active_words.clear()
	pending_spawns.clear()

	if not database:
		return

	current_question = database.get_next_question()
	question_index += 1

	if hud:
		hud.set_question(
			current_question.get("question", ""),
			current_question.get("category", "General"),
			question_index
		)

	_prepare_question_spawns()

func _prepare_question_spawns() -> void:
	var answer: String = current_question.get("answer", "")
	var distractors: Array = current_question.get("distractors", []).duplicate()
	distractors.shuffle()

	# Select 2 to 3 distractors
	var count = mini(3, distractors.size())
	var selected_distractors = distractors.slice(0, count)

	# Prepare list of items to drop
	var items: Array[Dictionary] = []
	items.append({"text": answer, "is_correct": true})
	for d in selected_distractors:
		items.append({"text": str(d), "is_correct": false})

	items.shuffle()
	
	# Generate distinct horizontal lanes across the screen
	# Screen width = 1152; safe margins between 130 and 1020
	var min_x = 130.0
	var max_x = 1020.0
	var total_items = items.size()
	var lane_width = (max_x - min_x) / float(total_items)

	var lanes: Array[int] = []
	for i in range(total_items):
		lanes.append(i)
	lanes.shuffle()

	# Stagger spawns with delay
	var current_delay = 0.2
	for i in range(total_items):
		var item = items[i]
		var lane_idx = lanes[i]
		var spawn_x = min_x + (lane_idx + 0.5) * lane_width + randf_range(-25.0, 25.0)

		pending_spawns.append({
			"delay": current_delay,
			"text": item.text,
			"is_correct": item.is_correct,
			"spawn_x": spawn_x
		})
		current_delay += randf_range(0.45, 0.75)

	is_wave_active = true

func _process(delta: float) -> void:
	# Camera shake decay
	if shake_intensity > 0.0 and camera:
		shake_intensity = maxf(0.0, shake_intensity - delta * 25.0)
		camera.offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)

	var is_paused = get_tree().paused if get_tree() else false
	if is_game_over or is_paused:
		return

	# Handle staggered spawns
	if pending_spawns.size() > 0:
		for i in range(pending_spawns.size() - 1, -1, -1):
			pending_spawns[i].delay -= delta
			if pending_spawns[i].delay <= 0.0:
				var info = pending_spawns[i]
				pending_spawns.remove_at(i)
				_spawn_word(info.text, info.is_correct, info.spawn_x)

	# Cleanup invalid/freed active words
	for i in range(active_words.size() - 1, -1, -1):
		if not is_instance_valid(active_words[i]):
			active_words.remove_at(i)

func _spawn_word(p_text: String, p_is_correct: bool, p_x: float) -> void:
	if not falling_word_scene or not words_container:
		return

	var word = falling_word_scene.instantiate() as Area2D
	var speed_mult = clampf(1.0 + float(questions_solved) * 0.035, 1.0, 1.8)
	word.position = Vector2(p_x, -40.0)
	if word.has_method("setup"):
		word.setup(p_text, p_is_correct, speed_mult)
	if word.has_signal("word_caught"):
		word.word_caught.connect(_on_word_caught_signal)
	if word.has_signal("word_missed"):
		word.word_missed.connect(_on_word_missed_signal)

	words_container.add_child(word)
	active_words.append(word)

func _on_player_word_caught(word_area: Area2D) -> void:
	var word = word_area
	if not word or bool(word.get("is_caught")):
		return

	var is_correct = bool(word.get("is_correct"))
	var word_pos = word.global_position
	if player and player.has_method("trigger_catch_animation"):
		player.trigger_catch_animation(is_correct)
	if word.has_method("catch_by_player"):
		word.catch_by_player()

	if is_correct:
		_handle_correct_catch(word_pos)
	else:
		_handle_wrong_catch(word_pos)

func _on_word_caught_signal(_is_correct: bool, _text: String, _pos: Vector2) -> void:
	# Handled in _on_player_word_caught
	pass

func _on_word_missed_signal(is_correct: bool, _text: String) -> void:
	if is_game_over:
		return

	if is_correct:
		# Player missed the correct answer!
		lives -= 1
		streak = 0
		if hud:
			hud.update_lives(lives, MAX_LIVES)
			hud.update_streak(streak)
			hud.flash_screen(Color(1.0, 0.45, 0.1, 0.3), 0.3)
			hud.show_floating_text("MISSED! -1 ❤️", Vector2(576, 520), Color(1.0, 0.6, 0.2))

		_play_sound("play_miss")
		_add_camera_shake(7.0)

		if lives <= 0:
			_trigger_game_over()
		else:
			# Advance or reload after short delay
			if get_tree():
				get_tree().create_timer(0.6).timeout.connect(_load_next_question)
			else:
				_load_next_question()
	else:
		# Distractor fell off safely
		_check_if_wave_exhausted()

func _check_if_wave_exhausted() -> void:
	# If no more spawns pending and no correct word remaining active
	if pending_spawns.is_empty():
		var has_correct = false
		for w in active_words:
			if is_instance_valid(w) and bool(w.get("is_correct")) and not bool(w.get("is_caught")):
				has_correct = true
				break
		if not has_correct and not is_game_over:
			# If correct word somehow vanished without triggering, advance
			if get_tree():
				get_tree().create_timer(0.5).timeout.connect(_load_next_question)
			else:
				_load_next_question()

func _handle_correct_catch(pos: Vector2) -> void:
	questions_solved += 1
	var multiplier = 1.0 + float(streak) * 0.5
	var earned = int(100.0 * multiplier)
	score += earned
	streak += 1

	if score > high_score:
		high_score = score
		_save_high_score()
		if hud:
			hud.update_high_score(high_score)

	if hud:
		hud.update_score(score)
		hud.update_streak(streak)
		hud.flash_screen(Color(0.2, 0.9, 0.4, 0.25), 0.2)
		var bonus_text = "+%d" % earned
		if streak >= 2:
			bonus_text = "+%d (x%.1f)" % [earned, multiplier]
		hud.show_floating_text(bonus_text, pos, Color(0.3, 1.0, 0.5))

	_play_sound("play_correct")
	if streak >= 3:
		_play_sound("play_streak")

	_add_camera_shake(3.0)

	# Transition to next question after brief delay
	if get_tree():
		get_tree().create_timer(0.65).timeout.connect(_load_next_question)
	else:
		_load_next_question()

func _handle_wrong_catch(pos: Vector2) -> void:
	lives -= 1
	streak = 0
	if hud:
		hud.update_lives(lives, MAX_LIVES)
		hud.update_streak(streak)
		hud.flash_screen(Color(1.0, 0.2, 0.2, 0.35), 0.35)
		hud.show_floating_text("WRONG! -1 ❤️", pos, Color(1.0, 0.3, 0.3))

	_play_sound("play_wrong")
	_add_camera_shake(12.0)

	if lives <= 0:
		_trigger_game_over()

func _add_camera_shake(amount: float) -> void:
	shake_intensity = maxf(shake_intensity, amount)

func _trigger_game_over() -> void:
	is_game_over = true
	_play_sound("play_game_over")
	_add_camera_shake(15.0)

	var is_new_best = score >= high_score and score > 0
	if hud:
		hud.show_game_over(score, high_score, questions_solved, is_new_best)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and (event.keycode == KEY_ESCAPE or event.keycode == KEY_P)):
		_toggle_pause()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_R:
		if is_game_over or (get_tree() and get_tree().paused):
			start_new_game()

func _toggle_pause() -> void:
	if is_game_over or not get_tree():
		return
	var will_pause = not get_tree().paused
	get_tree().paused = will_pause
	if hud:
		hud.set_pause_visible(will_pause)
	_play_sound("play_click")

func _on_restart_requested() -> void:
	_play_sound("play_click")
	start_new_game()

func _on_resume_requested() -> void:
	_toggle_pause()
