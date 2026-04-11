extends Node2D

@warning_ignore("narrowing_conversion")
@onready var cell_position: Vector2i = Vector2i(position.x/8,position.y/8)

@onready var interval_time:float = 60.0 / BeatManager.bpm
@export var note_number:int = 0

var tween:Tween

var direction:Vector2i = Vector2i.ZERO

var alive:bool = false #是否处于活跃状态

func on_beat() -> void:
	if not alive:
		return
	try_move()

func try_move() -> void:
	var target_cell_position := cell_position + direction
	#判定终点有无物体（箱子/玩家）
	var target_game_object:GameObject
	for game_object: GameObject in get_tree().get_nodes_in_group("GameObject"):
		if world_to_cell(game_object.position) == target_cell_position:
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
			#!!! if data.get_custom_data("is_sound_deflection"):
	move_to(target_cell_position)


func move_to(cell: Vector2i):
	cell_position = cell
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self,"position",cell_to_world(cell),interval_time)

func cell_to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell.x*8,cell.y*8)
	
func world_to_cell(world_position: Vector2) -> Vector2i:
	@warning_ignore("narrowing_conversion")
	return Vector2i(world_position.x/8,world_position.y/8)

func sound_absorbed() -> void:
	var cell = cell_position + direction
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self,"position",cell_to_world(cell),interval_time/2)
	await tween.finished
	cell_position.x += 114 #魔法数字移到魔法位置嘻嘻嘻
	visible = false
	alive = false
	EventManager.note_absorb.emit(note_number)

func sound_reflection() -> void:
	var cell = cell_position + direction
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self,"position",cell_to_world(cell),interval_time/2)
	await tween.finished
	direction = -direction
	play_note()
	cell = cell_position + direction
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self,"position",cell_to_world(cell),interval_time/2)
	
func sound_deflection(directions:Array) -> void:
	for i in directions:
		if directions[i] != direction:
			direction = directions[i]
			break
	play_note()

func _on_area_2d_area_entered(area: Area2D) -> void: #其他音符进入时，发出声音
	if not area.is_in_group("Notes"):
		return
	#！！！变色
	play_note()

func play_note() -> void:
	EventManager.play_note(note_number)
