extends Node

@export var bpm: float = 120

var beat_interval: float
var timer: float = 0.0

func _ready() -> void:
	AudioManager.play_bgm()
	beat_interval = 60.0 / bpm

func _physics_process(delta: float) -> void:
	timer += delta
	if timer >= beat_interval:
		timer -= beat_interval
		_on_beat()

func _on_beat() -> void:
	get_tree().call_group("Notes", "on_beat")
	get_tree().call_group("Player", "on_beat")
	get_tree().call_group("OnBeats", "on_beat")
