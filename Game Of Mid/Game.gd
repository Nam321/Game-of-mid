extends Node

@onready var combat_arena = $CombatArena

func _ready():
	enter_battle()

func enter_battle():
	combat_arena.initialize()
	await get_tree().create_timer(0.8).timeout
	combat_arena.battle_start()
