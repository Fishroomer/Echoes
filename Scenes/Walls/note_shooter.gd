extends "res://Script/Wall.gd"

@export var shooter_number:int = 0

var should_shoot:bool = false
var shooted:bool = false

func _ready() -> void:
	EventManager.color_button_pressed.connect(on_color_button_pressed)

func on_color_button_pressed(button_number:int) -> void:
	if button_number != shooter_number:
		return
	if shooted:
		return
	shooted = true
	should_shoot = true

func on_beat() -> void:
	if should_shoot:
		shoot_note(shooter_number)
		should_shoot = false

func shoot_note(shooter_number:int) -> void:
	note[note_number].cell_position = cell_position
	note[note_number].position = self.position
	note[note_number].shoot()
