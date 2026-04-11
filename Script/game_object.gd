class_name GameObject
extends Node2D

var tween:Tween

@export var sound_absorb:bool = false
@export var sound_reflection:bool = false
@export var sound_deflection:Array[Vector2i] = []

@onready var map: TileMapLayer = get_parent()
@onready var cell_position: Vector2i = map.local_to_map(position)

func move_to(cell: Vector2i):
	cell_position = cell
	#position = map.map_to_local(cell)
	
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self,"position",map.map_to_local(cell),0.2)

func is_wall(cell:Vector2i) -> bool:
	var data := map.get_cell_tile_data(cell)
	if not data:
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
