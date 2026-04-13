extends Node2D

@export var room_id:int = 0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _process(_delta: float) -> void:
	if EventManager.current_room == room_id:
		anim.play("open")
	else:
		anim.play("close")
