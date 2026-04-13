extends Wall

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
		shoot_note()
		should_shoot = false

func shoot_note() -> void:
	EventManager.notes_to_shoot[shooter_number].cell_position = cell_position
	EventManager.notes_to_shoot[shooter_number].position = self.position
	EventManager.notes_to_shoot[shooter_number].shoot()

func reset() -> void:
	if EventManager.current_room != room_number:
		return
	if EventManager.notes_to_shoot[shooter_number].wild:
		return
