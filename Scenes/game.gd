extends Node2D

@onready var level: TileMapLayer = $Level

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventManager.current_map = level
