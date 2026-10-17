extends Node



var _players: Array[AudioStreamPlayer] = []
var _player_index: int = 0
const MAX_PLAYERS: int = 8

var stream_correct: AudioStreamWAV
var stream_wrong: AudioStreamWAV
var stream_streak: AudioStreamWAV
var stream_miss: AudioStreamWAV
var stream_game_over: AudioStreamWAV
var stream_click: AudioStreamWAV
var stream_speed_boost: AudioStreamWAV

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Create pool of AudioStreamPlayers for polyphony
	for i in range(MAX_PLAYERS):
		var player := AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		_players.append(player)

	# Synthesize all sound effects
	stream_correct = _generate_arpeggio([523.25, 659.25, 783.99, 1046.5], 0.32, "sine")
	stream_wrong = _generate_buzz(130.0, 75.0, 0.28)
	stream_streak = _generate_arpeggio([659.25, 783.99, 987.77, 1318.5], 0.4, "bell")
	stream_miss = _generate_pitch_drop(380.0, 140.0, 0.3)
	stream_game_over = _generate_minor_cadence([440.0, 392.0, 329.63, 261.63], 0.9)
	stream_click = _generate_tone(880.0, 0.05, "sine", 0.3)
	stream_speed_boost = _generate_pitch_drop(220.0, 440.0, 0.15) # pitch rise actually

func _get_next_player() -> AudioStreamPlayer:
	var player = _players[_player_index]
	_player_index = (_player_index + 1) % MAX_PLAYERS
	return player

func play_correct() -> void:
	var p = _get_next_player()
	p.stream = stream_correct
	p.volume_db = -2.0
	p.play()

func play_wrong() -> void:
	var p = _get_next_player()
	p.stream = stream_wrong
	p.volume_db = 0.0
	p.play()

func play_streak() -> void:
	var p = _get_next_player()
	p.stream = stream_streak
	p.volume_db = 1.0
	p.play()

func play_miss() -> void:
	var p = _get_next_player()
	p.stream = stream_miss
	p.volume_db = -1.0
	p.play()

func play_game_over() -> void:
	var p = _get_next_player()
	p.stream = stream_game_over
	p.volume_db = 2.0
	p.play()

func play_click() -> void:
	var p = _get_next_player()
	p.stream = stream_click
	p.volume_db = -4.0
	p.play()

# ----------------- Sound Generation Algorithms -----------------

func _create_wav(byte_data: PackedByteArray, sample_rate: int = 44100) -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.data = byte_data
	return wav

func _generate_arpeggio(freqs: Array, total_duration: float, style: String = "sine") -> AudioStreamWAV:
	var sample_rate: int = 44100
	var total_samples: int = int(sample_rate * total_duration)
	var bytes := PackedByteArray()
	bytes.resize(total_samples * 2)

	var note_duration: float = total_duration / float(freqs.size())
	var note_samples: int = int(sample_rate * note_duration)

	for i in range(total_samples):
		var note_idx: int = clampi(int(i / note_samples), 0, freqs.size() - 1)
		var freq: float = freqs[note_idx]
		var t_note: float = float(i % note_samples) / float(sample_rate)
		var t_total: float = float(i) / float(sample_rate)

		# Envelope for each note: fast attack, exponential decay
		var env_note: float = exp(-t_note * 8.0) * minf(1.0, t_note * 100.0)
		var env_total: float = 1.0 - (t_total / total_duration)

		var val: float = 0.0
		var phase: float = TAU * freq * t_total
		if style == "bell":
			val = sin(phase) * 0.7 + sin(phase * 2.0) * 0.2 + sin(phase * 3.0) * 0.1
		else:
			val = sin(phase) * 0.8 + sin(phase * 2.0) * 0.2

		var sample_val: float = val * env_note * env_total * 0.6
		var sample_int: int = clampi(int(sample_val * 32767.0), -32768, 32767)
		var idx: int = i * 2
		bytes[idx] = sample_int & 0xFF
		bytes[idx + 1] = (sample_int >> 8) & 0xFF

	return _create_wav(bytes, sample_rate)

func _generate_buzz(start_freq: float, end_freq: float, duration: float) -> AudioStreamWAV:
	var sample_rate: int = 44100
	var total_samples: int = int(sample_rate * duration)
	var bytes := PackedByteArray()
	bytes.resize(total_samples * 2)

	var phase: float = 0.0
	for i in range(total_samples):
		var progress: float = float(i) / float(total_samples)
		var freq: float = lerpf(start_freq, end_freq, progress)
		phase += TAU * freq / float(sample_rate)

		# Sawtooth wave + square subharmonic for harsh buzzer
		var saw: float = (fposmod(phase, TAU) / PI) - 1.0
		var sqr: float = 1.0 if sin(phase * 0.5) > 0.0 else -1.0
		var env: float = (1.0 - progress) * minf(1.0, float(i) / 200.0)

		var sample_val: float = (saw * 0.6 + sqr * 0.3) * env * 0.45
		var sample_int: int = clampi(int(sample_val * 32767.0), -32768, 32767)
		var idx: int = i * 2
		bytes[idx] = sample_int & 0xFF
		bytes[idx + 1] = (sample_int >> 8) & 0xFF

	return _create_wav(bytes, sample_rate)

func _generate_pitch_drop(start_freq: float, end_freq: float, duration: float) -> AudioStreamWAV:
	var sample_rate: int = 44100
	var total_samples: int = int(sample_rate * duration)
	var bytes := PackedByteArray()
	bytes.resize(total_samples * 2)

	var phase: float = 0.0
	for i in range(total_samples):
		var progress: float = float(i) / float(total_samples)
		var freq: float = lerpf(start_freq, end_freq, progress * progress)
		phase += TAU * freq / float(sample_rate)

		var env: float = (1.0 - progress) * minf(1.0, float(i) / 300.0)
		var sample_val: float = sin(phase) * env * 0.5
		var sample_int: int = clampi(int(sample_val * 32767.0), -32768, 32767)
		var idx: int = i * 2
		bytes[idx] = sample_int & 0xFF
		bytes[idx + 1] = (sample_int >> 8) & 0xFF

	return _create_wav(bytes, sample_rate)

func _generate_minor_cadence(freqs: Array, total_duration: float) -> AudioStreamWAV:
	var sample_rate: int = 44100
	var total_samples: int = int(sample_rate * total_duration)
	var bytes := PackedByteArray()
	bytes.resize(total_samples * 2)

	var note_duration: float = total_duration / float(freqs.size())
	var note_samples: int = int(sample_rate * note_duration)

	for i in range(total_samples):
		var note_idx: int = clampi(int(i / note_samples), 0, freqs.size() - 1)
		var freq: float = freqs[note_idx]
		var t_note: float = float(i % note_samples) / float(sample_rate)
		var t_total: float = float(i) / float(sample_rate)

		var env_note: float = exp(-t_note * 4.0) * minf(1.0, t_note * 120.0)
		var env_total: float = 1.0 - (t_total / total_duration)

		var phase: float = TAU * freq * t_total
		var val: float = sin(phase) * 0.7 + sin(phase * 0.5) * 0.3
		var sample_val: float = val * env_note * env_total * 0.55
		var sample_int: int = clampi(int(sample_val * 32767.0), -32768, 32767)
		var idx: int = i * 2
		bytes[idx] = sample_int & 0xFF
		bytes[idx + 1] = (sample_int >> 8) & 0xFF

	return _create_wav(bytes, sample_rate)

func _generate_tone(freq: float, duration: float, _style: String = "sine", vol: float = 0.5) -> AudioStreamWAV:
	var sample_rate: int = 44100
	var total_samples: int = int(sample_rate * duration)
	var bytes := PackedByteArray()
	bytes.resize(total_samples * 2)

	for i in range(total_samples):
		var progress: float = float(i) / float(total_samples)
		var env: float = (1.0 - progress) * minf(1.0, float(i) / 100.0)
		var sample_val: float = sin(TAU * freq * (float(i) / sample_rate)) * env * vol
		var sample_int: int = clampi(int(sample_val * 32767.0), -32768, 32767)
		var idx: int = i * 2
		bytes[idx] = sample_int & 0xFF
		bytes[idx + 1] = (sample_int >> 8) & 0xFF

	return _create_wav(bytes, sample_rate)

