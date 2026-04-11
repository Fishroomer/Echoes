extends Node

var doors = [
	{
		"room": 0,
		"is_open": false
	}
] # 储存所有门的开关状态

var doors_password = {
	0: [[0,0,0,0,1],[0,0,0,1,1]]
} # 储存所有门的密码

var player_position:Vector2i = Vector2i(0,0)
var current_room:int = 0
var player_spawn_position:Vector2i = Vector2i(0,0)

var notes_history := [] # 最近40次音符
var notes := [0,0,0,0,0]  # 当前输入音符

@warning_ignore("unused_signal")
signal play_note(note_number:int)

signal open_door(door_number:int)

@warning_ignore("unused_signal")
signal change_room(room_number:int,camera_position:Vector2,new_player_spawn_position:Vector2i)

# 二进制数组 → 索引
func notes_to_index(arr: Array) -> int:
	var value = 0
	for i in range(arr.size()):
		value = value * 2 + arr[i]
	return value

func play_note_sfx() -> void:
	var index = notes_to_index(notes)

	# 自动映射音效（note_0 ~ note_31）
	AudioManager.play_sfx("note_" + str(index))

	# 存入历史
	notes_history.append(notes.duplicate())

	# 限制最多40条
	if notes_history.size() > 40:
		notes_history.pop_front()

	# 每次输入后尝试开门
	try_open_door()

	# 重置
	notes = [0,0,0,0,0]

func try_open_door() -> void:
	for door_id in doors_password.keys():
		var password = doors_password[door_id]
		var door = doors[door_id]

		## 房间限制
		#if door.room != current_room:
			#continue

		var password_len = password.size()

		if notes_history.size() < password_len:
			continue

		# 取最近输入
		var recent = notes_history.slice(notes_history.size() - password_len, notes_history.size())

		if recent == password:
			if not door.is_open:
				door.is_open = true
				emit_signal("open_door", door_id)

func _on_change_room(room_number, _camera_position: Vector2, new_player_spawn_position: Vector2i) -> void:
	current_room = room_number
	player_spawn_position = new_player_spawn_position

	# （可选）跨房间清空输入
	# notes_history.clear()
	# notes = [0,0,0,0,0]
