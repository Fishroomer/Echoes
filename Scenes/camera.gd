extends Camera2D

func _ready() -> void:
	EventManager.change_room.connect(on_change_room)

func on_change_room(_room_number,camera_position: Vector2, _new_player_spawn_position: Vector2i) -> void:
	self.position = camera_position
