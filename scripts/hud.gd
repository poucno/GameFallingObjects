class_name GameHUD
extends CanvasLayer

signal restart_requested
signal resume_requested

@onready var question_panel: PanelContainer = $BottomMargin/QuestionCard
@onready var question_label: Label = $BottomMargin/QuestionCard/HBox/VBox/QuestionLabel
@onready var category_label: Label = $BottomMargin/QuestionCard/HBox/CategoryBadge/CatMargin/CatLabel
@onready var category_badge: PanelContainer = $BottomMargin/QuestionCard/HBox/CategoryBadge
@onready var question_counter_label: Label = $BottomMargin/QuestionCard/HBox/CounterLabel

@onready var score_label: Label = $TopMargin/TopBar/RightBox/ScoreLabel
@onready var highscore_label: Label = $TopMargin/TopBar/RightBox/HighScoreLabel
@onready var streak_label: Label = $TopMargin/TopBar/CenterBox/StreakLabel
@onready var lives_box: HBoxContainer = $TopMargin/TopBar/LeftBox/HeartsContainer

@onready var screen_flash: ColorRect = $ScreenFlash
@onready var game_over_panel: Control = $GameOverOverlay
@onready var final_score_label: Label = $GameOverOverlay/Center/Card/Margin/VBox/FinalScore
@onready var final_stats_label: Label = $GameOverOverlay/Center/Card/Margin/VBox/StatsLabel
@onready var new_record_badge: Label = $GameOverOverlay/Center/Card/Margin/VBox/NewRecordLabel
@onready var restart_button: Button = $GameOverOverlay/Center/Card/Margin/VBox/BtnBox/RestartBtn

@onready var pause_panel: Control = $PauseOverlay
@onready var resume_button: Button = $PauseOverlay/Center/Card/Margin/VBox/BtnBox/ResumeBtn
@onready var pause_restart_button: Button = $PauseOverlay/Center/Card/Margin/VBox/BtnBox/PauseRestartBtn

var _displayed_score: int = 0
var _target_score: int = 0
var _score_tween: Tween

const HEART_FULL: String = "❤️"
const HEART_EMPTY: String = "🖤"

func _ready() -> void:
	game_over_panel.visible = false
	pause_panel.visible = false
	new_record_badge.visible = false
	streak_label.visible = false
	screen_flash.color = Color(0, 0, 0, 0)

	restart_button.pressed.connect(_on_restart_pressed)
	resume_button.pressed.connect(_on_resume_pressed)
	pause_restart_button.pressed.connect(_on_restart_pressed)

func set_question(question_text: String, category: String, index: int) -> void:
	question_label.text = question_text
	category_label.text = category.to_upper()
	question_counter_label.text = "Q #%d" % index

	# Distinct color per category
	var cat_color = _get_category_color(category)
	var cat_style = category_badge.get_theme_stylebox("panel") as StyleBoxFlat
	if cat_style:
		cat_style.bg_color = cat_color

	# Punch animation for bottom question card
	if question_panel:
		var tw = create_tween()
		question_panel.scale = Vector2(0.97, 0.97)
		tw.tween_property(question_panel, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _get_category_color(cat: String) -> Color:
	match cat.to_lower():
		"space": return Color(0.25, 0.45, 0.95, 0.85)
		"science": return Color(0.15, 0.75, 0.65, 0.85)
		"animals": return Color(0.85, 0.55, 0.15, 0.85)
		"geography": return Color(0.3, 0.65, 0.25, 0.85)
		"technology": return Color(0.65, 0.35, 0.9, 0.85)
		"food": return Color(0.95, 0.4, 0.2, 0.85)
		"math": return Color(0.85, 0.25, 0.45, 0.85)
		_: return Color(0.35, 0.55, 0.85, 0.85)

func update_score(new_score: int) -> void:
	_target_score = new_score
	if _score_tween and _score_tween.is_valid():
		_score_tween.kill()

	_score_tween = create_tween()
	_score_tween.tween_method(_animate_score_count, _displayed_score, _target_score, 0.35)

func _animate_score_count(val: int) -> void:
	_displayed_score = val
	score_label.text = "SCORE: %d" % _displayed_score

func update_high_score(best: int) -> void:
	highscore_label.text = "BEST: %d" % best

func update_lives(current_lives: int, max_lives: int = 3) -> void:
	var children = lives_box.get_children()
	for i in range(max_lives):
		if i < children.size():
			var heart = children[i] as Label
			if i < current_lives:
				heart.text = HEART_FULL
				heart.modulate = Color(1.0, 1.0, 1.0, 1.0)
			else:
				if heart.text == HEART_FULL:
					_pop_heart(heart)
				heart.text = HEART_EMPTY
				heart.modulate = Color(0.6, 0.6, 0.6, 0.5)

func _pop_heart(heart: Label) -> void:
	var tw = create_tween()
	tw.tween_property(heart, "scale", Vector2(1.5, 1.5), 0.1)
	tw.tween_property(heart, "scale", Vector2.ONE, 0.15)

func update_streak(streak: int) -> void:
	if streak >= 2:
		streak_label.visible = true
		streak_label.text = "STREAK x%d!" % streak
		var tw = create_tween()
		streak_label.scale = Vector2(1.3, 1.3)
		tw.tween_property(streak_label, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	else:
		streak_label.visible = false

func flash_screen(color: Color, duration: float = 0.25) -> void:
	screen_flash.color = color
	var tw = create_tween()
	tw.tween_property(screen_flash, "color:a", 0.0, duration)

func show_floating_text(text: String, world_pos: Vector2, color: Color) -> void:
	var float_label := Label.new()
	float_label.text = text
	float_label.add_theme_font_size_override("font_size", 22)
	float_label.add_theme_color_override("font_color", color)
	float_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	float_label.add_theme_constant_override("shadow_offset_y", 2)
	add_child(float_label)

	float_label.global_position = world_pos - Vector2(float_label.size.x * 0.5, 30.0)
	float_label.scale = Vector2(0.5, 0.5)

	var tw = create_tween().set_parallel(true)
	tw.tween_property(float_label, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(float_label, "global_position:y", float_label.global_position.y - 50.0, 0.65)
	tw.chain().tween_property(float_label, "modulate:a", 0.0, 0.25)
	tw.chain().tween_callback(float_label.queue_free)

func show_game_over(final_score: int, high_score: int, solved: int, is_new_record: bool) -> void:
	final_score_label.text = "%d" % final_score
	final_stats_label.text = "Questions Solved: %d   •   High Score: %d" % [solved, high_score]
	new_record_badge.visible = is_new_record

	game_over_panel.visible = true
	game_over_panel.modulate.a = 0.0
	var tw = create_tween()
	tw.tween_property(game_over_panel, "modulate:a", 1.0, 0.35)

func hide_game_over() -> void:
	game_over_panel.visible = false

func set_pause_visible(is_paused: bool) -> void:
	pause_panel.visible = is_paused

func _on_restart_pressed() -> void:
	restart_requested.emit()

func _on_resume_pressed() -> void:
	resume_requested.emit()

