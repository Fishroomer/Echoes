class_name Wall
extends Node2D

var tween:Tween

@export var is_wall:bool = false
@export var is_tunnel_door:bool = false
@export var is_single_way_door:bool = false
@export var sound_absorb:bool = false
@export var sound_reflection:bool = false
@export var sound_deflection:Vector4i = Vector4i(0,0,0,0)

@export var room_number:int = 0
@export var spawn_cell_position:Vector2i = Vector2i.ZERO

var map: TileMapLayer
@onready var cell_position: Vector2i

func set_map(m: TileMapLayer): #初始化地图函数，依赖注入
	map = m
	# 初始化位置
	position = map.map_to_local(spawn_cell_position)
	cell_position = spawn_cell_position

func reset():
	if EventManager.current_room != room_number:
		return
