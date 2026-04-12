extends Area2D

@export var room_number:int
@export var camera_Position:Vector2
@export var player_respawn_position:Vector2


func _on_area_entered(_area: Area2D) -> void:
	EventManager.change_room.emit(room_number,camera_Position,player_respawn_position)
