extends Marker2D

signal target_selected(battler)

@onready var anim_player = $Sprite2D/AnimationPlayer

@export var MOVE_DURATION : float = 0.1

var targets : Array
var target_active : Battler

func _ready():
	hide()

func select_target(battlers : Array) -> Battler:
	visible = true
	targets = battlers
	target_active = targets[0]
	scale.x = 1.0 if target_active.party_member else -1.0
	global_position = target_active.target_global_position
	anim_player.play("wiggle")
	var selected_target : Battler = await self.target_selected
	hide()
	return selected_target

func move_to(battler : Battler):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(
		self,
		"global_position",
		battler.target_global_position,
		MOVE_DURATION
	)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		emit_signal("target_selected", target_active)
	
	var index = targets.find(target_active)
	if event.is_action_pressed("ui_down"):
		target_active = targets[(index + 1) % targets.size()]
		move_to(target_active)
	if event.is_action_pressed("ui_up"):
		target_active = targets[(index - 1 + targets.size()) % targets.size()]
		move_to(target_active)
