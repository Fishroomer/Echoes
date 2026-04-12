extends Node2D

@onready var level: TileMapLayer = $Level

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventManager.current_map = level
	await get_tree().process_frame
	for obj in get_tree().get_nodes_in_group("GameObject"):
		obj.set_map(EventManager.current_map)
	for obj in get_tree().get_nodes_in_group("Wall"):
		obj.set_map(EventManager.current_map)
