extends SceneTree

var _timer: float = 0.0
var _tested_catch: bool = false
var _tested_wrong: bool = false

func _init() -> void:
	print("Starting complete integration test...")
	change_scene_to_file("res://scenes/main.tscn")

func _process(delta: float) -> bool:
	_timer += delta
	var current = current_scene
	if not current:
		return false

	var words: Array = current.get("active_words")

	# Wait until some words have spawned
	if not _tested_catch and words.size() >= 1:
		for w in words:
			if is_instance_valid(w) and bool(w.get("is_correct")):
				print("Testing correct catch on: ", w.get("word_text"))
				var old_score = int(current.get("score"))
				current._on_player_word_caught(w)
				var new_score = int(current.get("score"))
				assert(new_score > old_score, "Score did not increase on correct catch")
				print("Score increased from ", old_score, " to ", new_score, "! Streak is ", current.get("streak"))
				_tested_catch = true
				break

	if _tested_catch and not _tested_wrong and _timer > 1.8:
		# Test catching a distractor
		var distractor_words: Array = current.get("active_words")
		for w in distractor_words:
			if is_instance_valid(w) and not bool(w.get("is_correct")):
				print("Testing wrong catch on: ", w.get("word_text"))
				var old_lives = int(current.get("lives"))
				current._on_player_word_caught(w)
				var new_lives = int(current.get("lives"))
				assert(new_lives == old_lives - 1, "Lives did not decrease on wrong catch")
				print("Lives decreased from ", old_lives, " to ", new_lives, "! Streak reset to ", current.get("streak"))
				_tested_wrong = true
				break

	if _tested_catch and _tested_wrong and _timer > 2.5:
		print("All gameplay mechanics verified successfully!")
		quit(0)
		return true

	if _timer > 5.0:
		print("Timeout reached without completing all checks!")
		quit(1)
		return true

	return false

