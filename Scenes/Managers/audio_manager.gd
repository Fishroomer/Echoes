extends Node

@onready var sfx: Node = $SFX
@onready var bgm_player: AudioStreamPlayer2D = $BGMPlayer

enum Bus {Master,BGM,SFX}

func play_sfx(sfxname:String):
	var player := sfx.get_node(sfxname) as AudioStreamPlayer
	if not player:
		return
	player.play()

func play_bgm():
	bgm_player.play()

func get_volume(bus_index: int) -> float:
	var db := AudioServer.get_bus_volume_db(bus_index)
	return db_to_linear(db)
	
func set_volume(bus_index: int,v: float) -> void:
	var db := linear_to_db(v)
	AudioServer.set_bus_volume_db(bus_index,db)

func setup_ui_sounds(node:Node) -> void:
	var button := node as BaseButton
	if button:
		button.pressed.connect(play_sfx("buttonpress"))
	for child in node.get_children():
		setup_ui_sounds(child)
