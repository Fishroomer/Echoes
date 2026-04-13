extends Node2D

var could_quit:= false

func _ready() -> void:
	await get_tree().create_timer(0.2).timeout
	could_quit = true

func _unhandled_input(_event: InputEvent) -> void:
	if could_quit:
		get_tree().quit()
