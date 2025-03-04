extends Node2D

@onready var turn_queue : TurnQueue = $TurnQueue
@onready var interface = $CombatInterface
@onready var timeline = $Timeline
@onready var victory_screen = $VictoryScreen
@onready var defeat_screen = $DefeatScreen

var active : bool = false

func _ready():
	turn_queue.order_updated.connect(update_timeline)
	turn_queue.active_battler_changed.connect(_on_active_battler_changed)
	victory_screen.visible = false
	defeat_screen.visible = false
	
	if victory_screen.get_node("ColorRect/VBoxContainer/Restart"):
		victory_screen.get_node("ColorRect/VBoxContainer/Restart").pressed.connect(_on_restart_pressed)
	if victory_screen.get_node("ColorRect/VBoxContainer/Quit"):
		victory_screen.get_node("ColorRect/VBoxContainer/Quit").pressed.connect(_on_quit_pressed)

	if defeat_screen.get_node("ColorRect/VBoxContainer/Restart"):
		defeat_screen.get_node("ColorRect/VBoxContainer/Restart").pressed.connect(_on_restart_pressed)
	if defeat_screen.get_node("ColorRect/VBoxContainer/Quit"):
		defeat_screen.get_node("ColorRect/VBoxContainer/Quit").pressed.connect(_on_quit_pressed)

func initialize():
	var battlers = turn_queue.get_battlers()
	interface.initialize(battlers)
	turn_queue.initialize()
	update_timeline(turn_queue.get_children())

func battle_start():
	active = true
	await play_intro()
	play_turn()

func play_intro():
	for battler in turn_queue.get_party():
		battler.appear()
		await get_tree().create_timer(0.15).timeout
	await get_tree().create_timer(0.8).timeout
	for battler in turn_queue.get_monsters():
		battler.appear()
		await get_tree().create_timer(0.15).timeout
	await get_tree().create_timer(0.8).timeout

func battle_end():
	active = false
	if turn_queue.get_monsters().is_empty():
		show_victory()
	elif turn_queue.get_party().is_empty():
		show_defeat()
	else:
		
		print("Battle ended unexpectedly")

func show_victory():
	victory_screen.visible = true
	get_tree().paused = true

func show_defeat():
	defeat_screen.visible = true
	get_tree().paused = true

func _on_restart_pressed():
	print("Restart button pressed!")
	get_tree().paused = false
	# Get fresh copy of current scene
	var current_scene = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file(current_scene)

func _on_quit_pressed():
	print("Quit button pressed!")
	get_tree().paused = false
	# to work in editor
	if OS.has_feature("editor"):
		get_tree().quit() 
	else:
		get_tree().quit() 

func play_turn():
	var battler : Battler = get_active_battler()
	battler.selected = true
	
	var targets : Array = get_targets()
	if not targets:
		battle_end()
		return
	
	var target : Battler
	var action : CombatAction
	
	if battler.party_member:
		interface.update_actions(battler)
		target = await interface.select_target(targets)
		action = interface.selected_action
	else:
		target = battler.choose_target(targets)
		action = get_active_battler().actions.get_children().pick_random()
		
	await turn_queue.play_turn(target, action)
	
	battler.selected = false
	
	if turn_queue.get_monsters().is_empty():
		show_victory()
		active = false
		return
	elif turn_queue.get_party().is_empty():
		show_defeat()
		active = false
		return
	
	if active:
		play_turn()

func get_active_battler() -> Battler:
	return turn_queue.active_battler

func get_targets() -> Array:
	if get_active_battler().party_member:
		return turn_queue.get_monsters()
	else:
		return turn_queue.get_party()
		
func update_timeline(battlers: Array):
	
	var current_battlers = turn_queue.get_children() 
	var timeline_slots = timeline.get_children()
	
	for slot in timeline_slots:
		var texture_rect = slot.get_node("TextureRect")
		texture_rect.texture = null
	
	var active_index = current_battlers.find(turn_queue.active_battler)
	if active_index == -1:
		active_index = 0
	
	var rotated_battlers = current_battlers.slice(active_index) + current_battlers.slice(0, active_index)
	
	for i in range(min(rotated_battlers.size(), timeline_slots.size())):
		var battler = rotated_battlers[i]
		var slot = timeline_slots[i]
		var texture_rect = slot.get_node("TextureRect")
		if battler and texture_rect:
			texture_rect.texture = battler.get_portrait()
		
func _on_active_battler_changed(new_active_battler: Battler):
	var battlers = turn_queue.get_children()
	var active_index = battlers.find(new_active_battler)
	
