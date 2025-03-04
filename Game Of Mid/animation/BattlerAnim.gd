extends Marker2D

class_name BattlerAnim

@onready var anim = $AnimationPlayer

func play_stagger():
	anim.play("take_damage")
	await anim.animation_finished

func play_death():
	anim.play("death")
	await anim.animation_finished
