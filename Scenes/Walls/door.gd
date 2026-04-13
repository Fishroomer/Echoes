extends Wall

@export var password:Array[Array] = []
@export var door_id:int = 0

func _ready() -> void:
	EventManager.doors_password[door_id] = password
	EventManager.open_door.connect(on_open_door)
	EventManager.doors.append(Dictionary({
		"room": room_number,
		"is_open": false
	}))

func on_open_door(doorid:int) -> void:
	if doorid == door_id:
		open()

func open() -> void:
	print("我open!")
	self.visible = false
	is_wall = false
	sound_absorb = false

func reset():
	pass
