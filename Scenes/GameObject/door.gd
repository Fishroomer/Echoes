extends Node2D

@export var password:Array[Array] = []
@export var room:int = 0
@export var door_id:int = 0

func _ready() -> void:
	EventManager.doors_password[door_id] = password
	EventManager.open_door.connect(on_open_door)
	EventManager.doors.append(Dictionary({
		"room": room,
		"is_open": false
	}))

func on_open_door(doorid:int) -> void:
	if doorid == door_id:
		open()

func open() -> void:
	print("我open!")
	self.visible = false
