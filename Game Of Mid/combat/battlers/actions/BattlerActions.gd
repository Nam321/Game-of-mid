extends Node

@export var skill_action_scene: PackedScene

func initialize(skills : Array) -> void:
	for skill in skills:
		var new_skill = skill_action_scene.instantiate()
		new_skill.skill_to_use = skill
		add_child(new_skill)
