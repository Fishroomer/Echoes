extends Node

@export var bpm: float = 120
@export var offset_ms: float = 0.0 # 用于微调音乐和节奏的物理偏移

var beat_interval: float
var last_reported_beat: int = -1
var beat_progress: float = 0.0 # 0.0 到 1.0 的实时进度

func _ready() -> void:
	beat_interval = 60.0 / bpm
	AudioManager.play_bgm()

func _process(_delta: float) -> void:
	var bgm = AudioManager.bgm_player
	if not bgm or not bgm.playing: 
		# 如果音乐没播，强制重置状态防止玩家锁死
		beat_progress = 0.0
		return

	var time = bgm.get_playback_position() + AudioServer.get_time_since_last_mix()
	time -= AudioServer.get_output_latency()
	
	# 使用 wrapf 处理循环播放时的 beat 计算，防止数值过大或跳变
	var total_beats = time / beat_interval
	beat_progress = fmod(total_beats, 1.0)
	
	var current_beat = int(floor(total_beats))
	if current_beat != last_reported_beat: # 改为不等于，处理循环跳转
		last_reported_beat = current_beat
		_on_beat()

func _on_beat() -> void:
	# 广播给所有监听节拍的对象
	get_tree().call_group("OnBeats", "on_beat")
