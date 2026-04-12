extends "res://Script/game_object.gd"

var notes := [true,false,false,false] #右，上，左，下

@onready var right: Sprite2D = $Node/Right
@onready var up: Sprite2D = $Node/Up
@onready var left: Sprite2D = $Node/Left
@onready var down: Sprite2D = $Node/Down
@onready var eyes :Array[Sprite2D] = [right,up,left,down]
var magicnumber = [29,11,1,19] # 调整眼睛的贴图用的

@onready var blue_note: Node2D = $Notes/BlueNote
@onready var green_note: Node2D = $Notes/GreenNote
@onready var red_note: Node2D = $Notes/RedNote
@onready var yellow_note: Node2D = $Notes/YellowNote
@onready var note:Array[Note] = [blue_note,green_note,red_note,yellow_note]

func _ready() -> void:
	EventManager.note_absorb.connect(on_note_absorb)

func _process(_delta: float) -> void:
	update_eyes()
	
	if tween and tween.is_running():
		return
	
	if Input.is_action_pressed("RIGHT") and notes[0]:
		print("发射！")
		shoot_note(0)
	if Input.is_action_pressed("UP") and notes[1]:
		shoot_note(1)
	if Input.is_action_pressed("LEFT") and notes[2]:
		shoot_note(2)
	if Input.is_action_pressed("DOWN") and notes[3]:
		shoot_note(3)

	var dir := Vector2i(
		Input.get_vector("A","D","W","S").round()
	)
	if dir == Vector2i.ZERO:
		return
	if dir.x != 0:
		dir.y = 0
	
	var dest := cell_position + dir
	if is_wall(dest):
		bump(dest)
		return
		
	var crate := get_crate(dest)
	if crate:
		if not can_push_chain(dest, dir):
			bump(dest)
			return
		var chain = get_push_chain(dest, dir)
		# ⚠️ 关键：从后往前移动（避免覆盖）
		for i in range(chain.size() - 1, -1, -1):
			var c = chain[i]
			c.move_to(c.cell_position + dir)

	move_to(dest)

func bump(cell: Vector2i):
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self,"position",(2*position+map.map_to_local(cell))/3,0.1)
	tween.tween_property(self,"position",position,0.1)

func update_eyes():
	for i in range(notes.size()):
		var rect = eyes[i].region_rect
		if notes[i]:
			rect.position.x = magicnumber[i]
		else:
			rect.position.x = magicnumber[i] + 32
		eyes[i].region_rect = rect

func on_note_absorb(note_number:int) -> void:
	notes[note_number] = true

func shoot_note(note_number:int) -> void:
	note[note_number].cell_position = cell_position
	note[note_number].position = self.position
	note[note_number].shoot()
	notes[note_number] = false
