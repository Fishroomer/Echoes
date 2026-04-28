extends Node

var doors = [] # 储存所有门的开关状态

var doors_password = {
	
} # 储存所有门的密码

var note_position = {
	0:[Vector2(0,0),Vector2(0,0)],
	1:[Vector2(100,0),Vector2(0,0)],
	2:[Vector2(200,0),Vector2(0,0)],
	3:[Vector2(300,0),Vector2(0,0)]
}

var player_position:Vector2i = Vector2i(0,0)
var current_room:int = 0
var current_map:TileMapLayer
var player_spawn_cell_position:Vector2i = Vector2i(0,0)

var notes_history := [] # 最近40次音符
var notes := [0,0,0,0,0]  # 当前输入音符，右上左下，捣蛋，捣蛋会覆盖全部

var notes_to_shoot :Array[Note] = []

var button_state:bool = false
var open_button_count:int = 0

signal open_door(door_number:int)

@warning_ignore("unused_signal")
signal note_absorb(note_number:int)

@warning_ignore("unused_signal")
signal change_room(room_number:int,camera_position:Vector2,new_player_spawn_position:Vector2i)

signal node_history_update(index:int)

@warning_ignore("unused_signal")
signal screen_shake(shake_name:String)

@warning_ignore("unused_signal")
signal color_button_pressed(button_number:int)

@warning_ignore("unused_signal")
signal coin_collectied()

var coin_count:int = 0

func play_note(note_number:int):
	print("记录声音"+str(note_number))
	notes[note_number] = 1

# 二进制数组 → 索引
func notes_to_index(arr: Array) -> int:
	if arr[4] == 1:
		return 16
	var value = 0
	for i in range(4):
		value |= (arr[i] << i)
	return value

var esc_hold_time := 0.0
var esc_hold_threshold := 1.5 # 按住1秒退出

func _process(delta: float) -> void:
	if Input.is_action_pressed("ESC"):
		esc_hold_time += delta
		
		if esc_hold_time >= esc_hold_threshold:
			get_tree().quit()
	else:
		esc_hold_time = 0.0

func play_note_sfx() -> void:
	if notes[4] == 1:
		print("发出捣蛋音")
		AudioManager.play_sfx("捣蛋音")
		# 存入历史（建议统一成特殊标记）
		notes_history.append([0,0,0,0,1])
	else:
		var has_sound = false
		for i in range(4):
			if notes[i] == 1:
				has_sound = true
				print("发出声音", i)
		if not has_sound:
			return
		# 存入历史
		notes_history.append(notes.duplicate())
	# 限制最多17条
	if notes_history.size() > 17:
		notes_history.pop_front()
	node_history_update.emit(notes_to_index(notes))
	# 尝试开门
	try_open_door()
	# 重置
	notes = [0,0,0,0,0]

func try_open_door() -> void:
	for door_id in doors_password.keys():
		var password = doors_password[door_id]
		var door = doors[door_id]
		## 房间限制
		if door.room != current_room:
			continue
		var password_len = password.size()
		if notes_history.size() < password_len:
			continue
		# 取最近输入
		var recent = notes_history.slice(notes_history.size() - password_len, notes_history.size())
		if recent == password:
			if not door.is_open:
				door.is_open = true
				print("开！")
				emit_signal("open_door", door_id)
				
func _on_change_room(room_number, _camera_position: Vector2, new_player_spawn_position: Vector2i) -> void:
	current_room = room_number
	player_spawn_cell_position = new_player_spawn_position
	 #（可选）跨房间清空输入
	notes_history.clear()
	notes = [0,0,0,0,0]

func on_beat() -> void:
	await get_tree().process_frame
	play_note_sfx()
	open_button_count = 0
	for button:Wall_Button in get_tree().get_nodes_in_group("Buttons"):
		if button.open:
			open_button_count += 1
	var new_button_state :bool = false
	if open_button_count % 2 == 1:
		new_button_state = true
	else: 
		new_button_state = false
	if new_button_state != button_state:
		get_tree().call_group("OnButtonChange", "on_button_change")
		button_state = new_button_state


func _on_coin_collectied() -> void:
	coin_count += 1
	if coin_count == 3:
		Transition.change_scene("res://Scenes/thanks.tscn")
