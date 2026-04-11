extends Node

var doors = [
	{
		"room": 0,
		"is_open": false
	}
] #储存所有门的开关状态

var doors_password = {
	0: [[0,0,0,1],[0,0,1,1]]
} #储存所有门的密码

var player_position:Vector2i = Vector2i(0,0) #均用格子坐标
var current_room:int = 0
var player_spawn_position:Vector2i = Vector2i(0,0)

var notes_history := [] #储存最近40次响起的的音符
var notes := [0,0,0,0]  #储存最近这次响起的的音符

@warning_ignore("unused_signal")
signal play_note(note_number:int)

signal open_door(door_number:int)

@warning_ignore("unused_signal")
signal change_room(room_number:int,camera_position:Vector2,new_player_spawn_position:Vector2i)

func play_note_sfx() -> void:
	match notes:
		[0,0,0,1]:
			AudioManager.play_sfx("")
		[0,0,1,0]:
			AudioManager.play_sfx("")
		[0,1,0,0]:
			AudioManager.play_sfx("")
		[1,0,0,0]:
			AudioManager.play_sfx("")
		[0,0,1,1]:
			AudioManager.play_sfx("")
		[0,1,0,1]:
			AudioManager.play_sfx("")
		[1,0,0,1]:
			AudioManager.play_sfx("")
		[0,1,1,0]:
			AudioManager.play_sfx("")
		[1,0,1,0]:
			AudioManager.play_sfx("")
		[1,1,0,0]:
			AudioManager.play_sfx("")
		[1,1,1,0]:
			AudioManager.play_sfx("")
		[1,1,0,1]:
			AudioManager.play_sfx("")
		[1,0,1,1]:
			AudioManager.play_sfx("")
		[0,1,1,1]:
			AudioManager.play_sfx("")
		[1,1,1,1]:
			AudioManager.play_sfx("")
		_:
			pass
	notes_history.append(notes)
	# 只储存近40个音符集
	if notes_history.size() > 40:
		notes_history.pop_front()
	# 重置notes
	notes = [0,0,0,0]

func try_open_door() -> void:
	for door_id in doors_password.keys():
		var password = doors_password[door_id]
		var door = doors[door_id]
		# 只有在当前房间才判定开门
		if door.room != current_room:
			continue

		var password_len = password.size()

		if notes_history.size() < password_len:
			continue

		var recent = notes_history.slice(notes_history.size() - password_len, notes_history.size())
		if recent == password:
			door.is_open = true
			emit_signal("open_door", door_id)

func _on_change_room(room_number,_camera_position: Vector2, new_player_spawn_position: Vector2i) -> void:
	current_room = room_number
	player_spawn_position = new_player_spawn_position
	# 跨关卡清除最近输入
	notes_history = []
	notes = [0,0,0,0]
