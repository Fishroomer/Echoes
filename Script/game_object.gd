class_name GameObject
extends Node2D

var tween:Tween

@export var sound_absorb:bool = false
@export var sound_reflection:bool = false
@export var sound_deflection:Vector4i = Vector4i(0,0,0,0)

@export var room_number:int = 0
@export var spawn_cell_position:Vector2i = Vector2i.ZERO

var map: TileMapLayer
@onready var cell_position: Vector2i
@onready var interval_time:float = 60.0 / BeatManager.bpm


func set_map(m: TileMapLayer): #初始化地图函数，依赖注入
	map = m
	# 初始化位置
	position = map.map_to_local(spawn_cell_position)
	cell_position = spawn_cell_position

func reset():
	if EventManager.current_room != room_number:
		return
	self.position = map.map_to_local(spawn_cell_position)
	cell_position = spawn_cell_position
	
func move_to(cell: Vector2i):
	cell_position = cell
	#position = map.map_to_local(cell)
	
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self,"position",map.map_to_local(cell),interval_time)

func is_wall(cell:Vector2i) -> bool:
	var data := map.get_cell_tile_data(cell)
	if not data:
		for wall: Wall in get_tree().get_nodes_in_group("Wall"):
			if wall.cell_position == cell:
				#！！！如果是管道门这种复杂情况要添加逻辑
				if wall.is_tunnel_door:
					var tunnel_door:Tunnel_door = wall
					if not tunnel_door.direction:
						if (cell_position - cell).x == 0:
							return false
						else:
							return true
					else:
						if (cell_position - cell).y == 0:
							return false
						else:
							return true
				return wall.is_wall
		return false
	return data.get_custom_data("is_wall")

func get_crate(cell:Vector2i) -> GameObject:
	for crate: GameObject in get_tree().get_nodes_in_group("crates"):
		if crate.cell_position == cell:
			return crate
	return null

func can_push_chain(cell: Vector2i, dir: Vector2i) -> bool:
	if is_wall(cell):
		return false
	var crate = get_crate(cell)
	if crate == null:
		return true  # 找到空位，可以推
	return can_push_chain(cell + dir, dir)
	
func get_push_chain(cell: Vector2i, dir: Vector2i, chain := []) -> Array:
	var crate = get_crate(cell)
	if crate == null:
		return chain
	chain.append(crate)
	return get_push_chain(cell + dir, dir, chain)
