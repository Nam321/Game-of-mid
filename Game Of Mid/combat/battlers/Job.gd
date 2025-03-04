@tool
extends Node

class_name Job


@onready var stats = $Stats
@onready var skills = $Skills

@export var starting_stats : Resource
@export var starting_skills : Array
@export var character_skill_scene: PackedScene

func _ready():
	stats.initialize(starting_stats)
	if starting_skills != null and starting_skills.size() > 0:
		for skill in starting_skills:
			var new_skill = character_skill_scene.instantiate()
			new_skill.initialize(skill)
			skills.add_child(new_skill)
