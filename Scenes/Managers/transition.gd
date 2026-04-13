extends CanvasLayer

@onready var anim: AnimationPlayer = $AnimationPlayer

var is_busy := false

func change_scene(path: String) -> void:
	if is_busy:
		return
	is_busy = true

	# 先变黑
	anim.play("fade_out")
	await anim.animation_finished
	# 切场景（此时玩家看不到）
	get_tree().change_scene_to_file(path)
	# 等一帧，确保新场景 ready
	await get_tree().process_frame
	# 再淡入
	anim.play("fade_in")
	await anim.animation_finished

	is_busy = false
