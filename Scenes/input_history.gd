extends Node2D

@onready var notes: Node2D = $Notes

@onready var _1: AnimatedSprite2D = $"Notes/1"
@onready var _2: AnimatedSprite2D = $"Notes/2"
@onready var _3: AnimatedSprite2D = $"Notes/3"
@onready var _4: AnimatedSprite2D = $"Notes/4"
@onready var _5: AnimatedSprite2D = $"Notes/5"
@onready var _6: AnimatedSprite2D = $"Notes/6"
@onready var _7: AnimatedSprite2D = $"Notes/7"
@onready var _8: AnimatedSprite2D = $"Notes/8"
@onready var _9: AnimatedSprite2D = $"Notes/9"
@onready var _10: AnimatedSprite2D = $"Notes/10"
@onready var _11: AnimatedSprite2D = $"Notes/11"
@onready var _12: AnimatedSprite2D = $"Notes/12"
@onready var _13: AnimatedSprite2D = $"Notes/13"
@onready var _14: AnimatedSprite2D = $"Notes/14"
@onready var _15: AnimatedSprite2D = $"Notes/15"
@onready var _16: AnimatedSprite2D = $"Notes/16"
@onready var _17: AnimatedSprite2D = $"Notes/17"

@onready var quene :Array[AnimatedSprite2D]= [_1,_2,_3,_4,_5,_6,_7,_8,_9,_10,_11,_12,_13,_14,_15,_16,_17]

const SPACING := 16
const MAX_VISIBLE := 16

var is_moving := false

func _ready():
	EventManager.node_history_update.connect(push_note)
	for i in range(quene.size()):
		quene[i].position.x = i * SPACING


func push_note(index: int):
	if is_moving:
		return
	is_moving = true
	# 先预处理
	_prepare_next_note(index)
	# 再移动
	var tween = create_tween()
	tween.tween_property(notes, "position:x", notes.position.x - SPACING, 0.2)

	tween.finished.connect(func():
		_recycle_only()
		is_moving = false
	)

func _prepare_next_note(index: int):
	var last = quene[-1]

	if index == 0:
		last.visible = false
	else:
		last.visible = true
		last.play(str(index))

func _recycle_only():
	var first = quene.pop_front()
	quene.append(first)
	# 重置父节点位置
	notes.position.x += SPACING
	# 重排位置
	for i in range(quene.size()):
		quene[i].position.x = i * SPACING

func _recycle_and_update(index: int):
	# 取出最左
	var first = quene.pop_front()
	# 放到队尾
	quene.append(first)
	notes.position.x += SPACING
	for i in range(quene.size()):
		quene[i].position.x = i * SPACING
	# 👉 设置新内容（最右）
	var last = quene[-1]
	if index == 0:
		last.visible = false
	else:
		last.visible = true
		last.play(str(index)) # 动画名 = index
