extends Node2D

class_name TurnQueue

@onready var active_battler : Battler
signal order_updated(battlers)
signal active_battler_changed(new_active_battler: Battler)

func initialize():
	
	var battlers = get_children()
	battlers.sort_custom(sort_battlers)
	
	
	for i in battlers.size():
		var battler = battlers[i]
		move_child(battler, i)
	
	active_battler = battlers[0]  
	emit_signal("order_updated", battlers)
	
func play_turn(target : Battler, action : CombatAction):
	await active_battler.play_turn(target, action)
	for battler in get_children():
		if battler.stats.health <= 0:
			remove_child(battler)
			battler.queue_free()
	
	var new_index : int = (active_battler.get_index() + 1) % get_child_count()
	active_battler = get_child(new_index)
	emit_signal("order_updated", get_children())
	emit_signal("active_battler_changed", active_battler)

static func sort_battlers(a : Battler, b : Battler) -> bool:
	return a.stats.speed > b.stats.speed

func print_queue():
	
	var string : String
	for battler in get_children():
		string += battler.name + "(%s)" % battler.stats.speed + " "
	print(string)

func get_party():
	return _get_targets(true)

func get_monsters():
	return _get_targets(false)

func _get_targets(in_party : bool = false) -> Array:
	var targets : Array = []
	for child in get_children():
		if child.party_member == in_party:
			targets.append(child)
	return targets

func get_battlers():
	return get_children()
	
func initialize_from_save(battler_states: Array):
	for child in get_children():
		remove_child(child)
		child.queue_free()
	
	for state in battler_states:
		var battler = load(state.scene).instantiate()
		add_child(battler)
		battler.stats.health = state.health
		battler.stats.max_health = state.max_health

func get_battler_states() -> Array:
	var states = []
	for battler in get_children():
		states.append({
			"scene": battler.scene_file_path,
			"health": battler.stats.health,
			"max_health": battler.stats.max_health
		})
	return states
