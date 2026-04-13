extends "res://Script/Wall.gd"

@export var button_number:int = 0

var open:bool = false

func on_beat() -> void:
	if get_gameobject() and not open:
		open = true 
		EventManager.color_button_pressed.emit(button_number)

func get_gameobject() -> bool:
	for crate: GameObject in get_tree().get_nodes_in_group("crates"):
		if crate.cell_position == cell_position:
			return true
	for player: GameObject in get_tree().get_nodes_in_group("Player"):
		if player.cell_position == cell_position:
			return true
	return false
