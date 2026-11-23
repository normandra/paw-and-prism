class_name SfxManager
extends Node

const SAMPLE_RATE: int = 22050
const POOL_SIZE: int = 12

var muted: bool = false
var _streams: Dictionary = {}
var _players: Array[AudioStreamPlayer] = []
var _next_player: int = 0
var _last_play_ms: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for _i in range(POOL_SIZE):
		var p: AudioStreamPlayer = AudioStreamPlayer.new()
		p.volume_db = -8.0
		add_child(p)
		_players.append(p)
	_build_all_samples()

func _build_all_samples() -> void:
	_streams["xp_plink"] = _synth_tone(780.0, 1080.0, 0.065, 0.18, "sine")
	_streams["hit_pop"] = _synth_tone(240.0, 115.0, 0.055, 0.22, "triangle")
	_streams["crit_sparkle"] = _synth_chord([720.0, 1080.0, 1440.0], 0.14, 0.24)
	_streams["player_hurt"] = _synth_tone(190.0, 82.0, 0.18, 0.36, "saw")
	_streams["dash_whoosh"] = _synth_noise(0.16, 0.22)
	_streams["loot_common"] = _synth_tone(520.0, 680.0, 0.11, 0.24, "sine")
	_streams["loot_rare"] = _synth_chord([523.25, 659.25, 783.99, 1046.5], 0.34, 0.30)
	_streams["loot_unique"] = _synth_chord([440.0, 554.37, 659.25, 880.0, 1318.5], 0.55, 0.38)
	_streams["gem_drop"] = _synth_chord([880.0, 1174.66, 1567.98], 0.28, 0.30)
	_streams["level_up"] = _synth_chord([523.25, 659.25, 783.99, 1046.5], 0.45, 0.35)
	_streams["boss_horn"] = _synth_tone(146.83, 110.0, 0.65, 0.42, "saw")
	_streams["ui_click"] = _synth_tone(620.0, 740.0, 0.045, 0.16, "sine")
	_streams["equip_snap"] = _synth_tone(340.0, 510.0, 0.09, 0.25, "triangle")
	_streams["socket_chime"] = _synth_chord([784.0, 1174.66], 0.18, 0.26)
	_streams["victory_fanfare"] = _synth_chord([523.25, 659.25, 783.99, 1046.5, 1318.5], 0.85, 0.40)

func toggle_mute() -> bool:
	muted = not muted
	return muted

func play(sfx_name: String, pitch_jitter: float = 0.07, min_interval_ms: int = 35) -> void:
	if muted or not _streams.has(sfx_name) or _players.is_empty():
		return
	var now: int = Time.get_ticks_msec()
	var prev: int = int(_last_play_ms.get(sfx_name, 0))
	if now - prev < min_interval_ms:
		return
	_last_play_ms[sfx_name] = now

	var p: AudioStreamPlayer = _players[_next_player]
	_next_player = (_next_player + 1) % _players.size()
	p.stream = _streams[sfx_name]
	p.pitch_scale = 1.0 + randf_range(-pitch_jitter, pitch_jitter)
	p.play()

func get_loaded_sample_names() -> Array[String]:
	var out: Array[String] = []
	for k in _streams.keys():
		out.append(String(k))
	return out

func _synth_tone(freq_start: float, freq_end: float, dur: float, amp: float, wave: String) -> AudioStreamWAV:
	var count: int = int(SAMPLE_RATE * dur)
	var buf: PackedByteArray = PackedByteArray()
	buf.resize(count * 2)
	var phase: float = 0.0
	for i in range(count):
		var t: float = float(i) / float(maxi(1, count))
		var freq: float = lerpf(freq_start, freq_end, t)
		phase += TAU * freq / float(SAMPLE_RATE)
		var raw: float = 0.0
		match wave:
			"triangle":
				raw = 2.0 * absf(2.0 * (phase / TAU - floorf(phase / TAU + 0.5))) - 1.0
			"saw":
				raw = 2.0 * (phase / TAU - floorf(0.5 + phase / TAU))
			_:
				raw = sin(phase)
		var env: float = sin(minf(1.0, t * 14.0) * PI * 0.5) * pow(1.0 - t, 1.5)
		var sample_i: int = clampi(int(raw * env * amp * 32767.0), -32767, 32767)
		buf.encode_s16(i * 2, sample_i)
	return _wrap_wav(buf)

func _synth_chord(freqs: Array, dur: float, amp: float) -> AudioStreamWAV:
	var count: int = int(SAMPLE_RATE * dur)
	var buf: PackedByteArray = PackedByteArray()
	buf.resize(count * 2)
	var n: float = float(maxi(1, freqs.size()))
	for i in range(count):
		var t: float = float(i) / float(maxi(1, count))
		var sum: float = 0.0
		for f in freqs:
			sum += sin(TAU * float(f) * (float(i) / float(SAMPLE_RATE)))
		var env: float = minf(1.0, t * 20.0) * pow(1.0 - t, 1.8)
		var sample_i: int = clampi(int((sum / n) * env * amp * 32767.0), -32767, 32767)
		buf.encode_s16(i * 2, sample_i)
	return _wrap_wav(buf)

func _synth_noise(dur: float, amp: float) -> AudioStreamWAV:
	var count: int = int(SAMPLE_RATE * dur)
	var buf: PackedByteArray = PackedByteArray()
	buf.resize(count * 2)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 1234
	var lowpass: float = 0.0
	for i in range(count):
		var t: float = float(i) / float(maxi(1, count))
		lowpass = lerpf(lowpass, rng.randf_range(-1.0, 1.0), 0.25)
		var env: float = sin(t * PI)
		var sample_i: int = clampi(int(lowpass * env * amp * 32767.0), -32767, 32767)
		buf.encode_s16(i * 2, sample_i)
	return _wrap_wav(buf)

func _wrap_wav(pcm_data: PackedByteArray) -> AudioStreamWAV:
	var wav: AudioStreamWAV = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	wav.data = pcm_data
	return wav
