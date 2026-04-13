extends Camera2D

@export var shake_strenth := {
	"dash":2.0
	}
@export var shake_recovery := {
	"dash":10.0
	}

var recovery := 0.0
var strength := 0.0
var camera_tween: Tween

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

# 建议在类开头定义一个变量来存储当前运行的 tween


func on_change_room(_room_number, camera_position: Vector2, _new_player_spawn_position: Vector2i) -> void:
	# 1. 如果当前已经有一个动画在跑，先停止它，防止位置冲突
	if camera_tween:
		camera_tween.kill()
	# 2. 创建一个新的 Tween
	camera_tween = create_tween()
	# 3. 设置平滑曲线（可选，TRANS_QUART 或 TRANS_SINE 通常手感较好）
	camera_tween.set_trans(Tween.TRANS_SINE)
	camera_tween.set_ease(Tween.EASE_OUT)
	# 4. 执行补间动画：在 0.2 秒内将 global_position 移动到目标位置
	camera_tween.tween_property(self, "global_position", camera_position, 0.2)
