extends Node2D

@export var TURN_START_MOVE_DISTANCE : float = 40.0
@export var TWEEN_DURATION : float = 0.3

@onready var anim = $AnimationPlayer
var battler_anim : BattlerAnim
@onready var position_start : Vector2

var blink : bool = false: set = set_blink

func _ready():
	hide()
	for child in get_children():
		if child is BattlerAnim:
			battler_anim = child
			break

func move_forward():
	var direction = Vector2(-1.0, 0.0) if owner.is_in_group("party") else Vector2(1.0, 0.0)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		self,
		"position",
		position_start + TURN_START_MOVE_DISTANCE * direction,
		TWEEN_DURATION
	)
	await tween.finished

func move_to(target : Battler):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		self,
		"global_position",
		target.target_global_position,
		TWEEN_DURATION
	)
	await tween.finished

func return_to_start():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		self,
		"position",
		position_start,
		TWEEN_DURATION
	)
	await tween.finished

func set_blink(value):
	blink = value
	if blink:
		anim.play("blink")
	else:
		anim.play("idle")

func play_stagger():
	battler_anim.play_stagger()

func play_death():
	await battler_anim.play_death()

func appear():
	anim.play("appear")

func get_portrait() -> Texture2D:
	if battler_anim:
		var body_sprite = battler_anim.get_node("body") 
		if body_sprite:
			return body_sprite.texture
	return null
