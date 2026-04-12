extends Node2D

@onready var wall: TileMapLayer = $wall

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventManager.current_map = wall
