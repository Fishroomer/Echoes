class_name Note
extends Node2D

@warning_ignore("narrowing_conversion")
@onready var cell_position: Vector2i = Vector2i(position.x/8,position.y/8)

@onready var interval_time:float = 60.0 / BeatManager.bpm / 2

@export var note_number:int = 0
@export var deault_direction:Vector2i = Vector2i.ZERO

var shooted:bool = false

var tween:Tween

var direction:Vector2i = Vector2i.ZERO

var alive:bool = false #是否处于活跃状态

var wild:bool = true #是否处于野生状态

#region 处理转向
const DIR_UP = Vector2i(0, -1)
const DIR_DOWN = Vector2i(0, 1)
const DIR_LEFT = Vector2i(-1, 0)
const DIR_RIGHT = Vector2i(1, 0)

func dir_to_index(dir: Vector2i) -> int:
	if dir == Vector2i(1, 0): return 0   # 右
	if dir == Vector2i(0, -1): return 1  # 上
	if dir == Vector2i(-1, 0): return 2  # 左
	if dir == Vector2i(0, 1): return 3   # 下
	return -1
	
func index_to_dir(i: int) -> Vector2i:
	match i:
		0: return Vector2i(1, 0)   # 右
		1: return Vector2i(0, -1)  # 上
		2: return Vector2i(-1, 0)  # 左
		3: return Vector2i(0, 1)   # 下
	return Vector2i.ZERO
#endregion

func on_beat() -> void:
	if shooted:
		self.visible = true
		self.alive = true
		self.direction = self.deault_direction
		shooted = false
	if not alive:
		return
	try_move()

func try_move() -> void:
	var target_cell_position := cell_position + direction
	#判定终点有无物体（箱子/玩家）
	var target_game_object:GameObject
	for game_object: GameObject in get_tree().get_nodes_in_group("GameObject"):
		if game_object.cell_position == target_cell_position:
			target_game_object = game_object
	if target_game_object:
		if target_game_object.sound_absorb:
			sound_absorbed()
			return
		if target_game_object.sound_reflection:
			sound_reflection()
			return
		if target_game_object.sound_deflection:
			sound_deflection(target_game_object.sound_deflection)
			move_to(target_cell_position)
			return
	
	#判定终点有无墙体（单向门/机关门/次序门）
	var target_wall:Wall
	for wall: Wall in get_tree().get_nodes_in_group("Wall"):
		if wall.cell_position == target_cell_position:
			target_wall = wall
	if target_wall:
		if target_wall.is_single_way_door:
			var single_way_door:SingleWayDoor = target_wall
			#如果是，则比对singlewaydoor的dir和dir，若相反则反射，其他情况无视
			if single_way_door.direction + direction == Vector2i.ZERO: 
				sound_reflection()
				return
		if target_wall.is_tunnel_door:
			var tunnel_door:Tunnel_door = target_wall
			# 若false（上下开），若dir.x != 0则反射，其他情况无视;若true（左右开），若dir.y != 0则反射，其他情况无视
			if(not tunnel_door.direction and direction.x != 0) or (tunnel_door.direction and direction.y != 0):
				sound_reflection()
				return
		if target_wall.sound_absorb:
			sound_absorbed()
			return
		if target_wall.sound_reflection:
			sound_reflection()
			return
	
	#判定终点在map上格子的性质（反射/吸收/折射）
	if EventManager.current_map:
		var cell = EventManager.current_map.local_to_map(EventManager.current_map.to_local(cell_to_world(target_cell_position)))
		var data := EventManager.current_map.get_cell_tile_data(cell)
		if data:
			if data.get_custom_data("is_sound_absorb"):
				sound_absorbed()
				return
			if data.get_custom_data("is_sound_reflection"):
				sound_reflection()
				return
			if data.get_custom_data("sound_deflection"):
				sound_deflection(data.get_custom_data("sound_deflection"))
	move_to(target_cell_position)

func move_to(cell: Vector2i):
	cell_position = cell
	
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "position", cell_to_world(cell), interval_time)

func cell_to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell.x*8+4,cell.y*8+4 )
	
func world_to_cell(world_position: Vector2) -> Vector2i:
	@warning_ignore("narrowing_conversion", "integer_division")
	return Vector2i(world_position.x+4/8,world_position.y+4/8)

func sound_absorbed() -> void:
	print("被吸收")
	var cell = cell_position + direction
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self,"position",(cell_to_world(cell_position)+cell_to_world(cell))/2,interval_time/2)
	await tween.finished
	dead()

func sound_reflection() -> void:
	print("被反射")
	var cell = cell_position + direction
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self,"position",(cell_to_world(cell_position)*2+cell_to_world(cell))/3,interval_time/2)
	await tween.finished
	direction = - direction
	play_note()
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self,"position",cell_to_world(cell_position),interval_time/2)

func sound_deflection(deflect_map: Vector4i) -> void: #折射
	var i = dir_to_index(direction)
	if i == -1:
		return
	var new_index = deflect_map[i]
	direction = index_to_dir(new_index)
	play_note()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if not alive or not area.get_parent().alive:
		return
	if not area.is_in_group("Notes"):
		return
	play_note()

func play_note() -> void:
	EventManager.play_note(note_number)

func dead() -> void:
	#第一次回收则不再野生
	if wild:
		wild = false
	cell_position.x += 114 #魔法数字移到魔法位置嘻嘻嘻
	visible = false
	alive = false
	EventManager.note_absorb.emit(note_number)

func shoot() -> void:
	shooted = true

func reset() -> void:
	#如果处于野生状态，额外逻辑
	if wild:
		return
	dead()
