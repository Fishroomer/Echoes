class_name Wall_Button
extends "res://Script/Wall.gd"

var open:bool = false

func on_beat() -> void:
	open = get_gameobject()

func get_gameobject() -> bool:
	for crate: GameObject in get_tree().get_nodes_in_group("crates"):
		if crate.cell_position == cell_position:
			return true
	for player: GameObject in get_tree().get_nodes_in_group("Player"):
		if player.cell_position == cell_position:
			return true
	return false
