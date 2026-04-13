extends Camera2D

@export var shake_strenth := {
	"dash":2.0
	}
@export var shake_recovery := {
	"dash":10.0
	}

var recovery := 0.0
var strength := 0.0

func screen_shake(delta) -> void:
	if strength != 0:
		offset = Vector2(randf_range(-strength,+strength),randf_range(-strength,+strength))
		strength = move_toward(strength, 0.0, recovery*delta)
		
func apply_screen_shake(shake_name:String) -> void:
	if shake_name not in shake_recovery:
		push_warning("未找到该震动！")
		return
	if shake_recovery[shake_name] > recovery:
		recovery = shake_recovery[shake_name]
	strength += shake_strenth[shake_name]

func _process(delta: float) -> void:
	screen_shake(delta)

func _ready() -> void:
	EventManager.change_room.connect(on_change_room)
	EventManager.screen_shake.connect(on_screen_shake)

func on_screen_shake(shake_name:String) -> void:
	apply_screen_shake(shake_name)

func on_change_room(_room_number,camera_position: Vector2, _new_player_spawn_position: Vector2i) -> void:
	self.global_position = camera_position
