extends "res://Script/game_object.gd"

@onready var emoji: AnimatedSprite2D = $emoji
@onready var face: AnimatedSprite2D = $face

var active:bool = false

@export var beat_count:int = 4
var count_beat:int = 0


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("Player"):
		emoji.play("awake")
		active = true

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.get_parent().is_in_group("Player"):
		face.play("default")
		emoji.play("sleep")
		active = false

func on_beat() -> void:
	if not active:
		return
	count_beat+=1
	face.play("default")
	if count_beat >= beat_count:
		face.play("shoot")
		count_beat = 0
		EventManager.play_note(4)
