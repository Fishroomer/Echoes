extends "res://Script/Wall.gd"

var open:bool = false

func on_beat() -> void:
	if get_gameobject() and not open:
		open = true 
		EventManager.coin_collectied.emit()
		self.visible = false 
		self.remove_from_group("OnBeats")

func get_gameobject() -> bool:
	for crate: GameObject in get_tree().get_nodes_in_group("crates"):
		if crate.cell_position == cell_position:
			return true
	for player: GameObject in get_tree().get_nodes_in_group("Player"):
		if player.cell_position == cell_position:
			return true
	return false
