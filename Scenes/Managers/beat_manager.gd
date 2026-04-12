extends Node

@export var bpm: float = 120

@onready var timer: Timer = $Timer

var beat_interval: float

func _ready() -> void:
	AudioManager.play_bgm()
	beat_interval = 60.0 / bpm
	timer.start(beat_interval)

func _on_beat() -> void:
	get_tree().call_group("OnBeats", "on_beat")

func _on_timer_timeout() -> void:
	_on_beat()
