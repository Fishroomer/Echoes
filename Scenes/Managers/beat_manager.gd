extends Node

@export var bpm: float = 120

var beat_interval: float
var timer: float = 0.0

func _ready() -> void:
	beat_interval = 60.0 / bpm

func _physics_process(delta: float) -> void:
	timer += delta
	if timer >= beat_interval:
		timer -= beat_interval
		_on_beat()

func _on_beat() -> void:
	#!!!处理玩家发射音符
	AudioManager.play_bgm() #播放节拍器音效
	get_tree().call_group("Notes", "on_beat")
	get_tree().call_group("Player", "on_beat")
	get_tree().call_group("OnBeats", "on_beat")
