class_name Tunnel_door
extends "res://Script/Wall.gd"

@export var default_direction := false #false为上下，true为左右,左右的话rect.x为8

var direction := false

@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	direction = default_direction
	if default_direction:
		sprite_2d.region_rect.position.x = 8
	else:
		sprite_2d.region_rect.position.x = 0

func on_button_change():
	direction = not direction
	if direction:
		sprite_2d.region_rect.position.x = 8
	else:
		sprite_2d.region_rect.position.x = 0
