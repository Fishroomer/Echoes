extends Node2D

var can_input:bool = false

func _ready() -> void:
	await get_tree().process_frame
	can_input = true

func _unhandled_input(event: InputEvent) -> void:
	if not can_input:
		return
	if event.is_action_pressed("ESC"):
		get_tree().quit()
	# 过滤掉鼠标移动（你之前踩的坑）
	if event is InputEventMouseMotion:
		return
	# 任意“按下”事件
	if event.is_pressed():
		can_input = false
		Transition.change_scene("res://Scenes/game.tscn")
