extends Marker2D

class_name Battler

@export var TARGET_OFFSET_DISTANCE : float = 120.0

const target_lowest_health_chance = 0.5
@onready var stats : CharacterStats = $Job/Stats as CharacterStats
@onready var lifebar_anchor = $InterfaceAnchor
@onready var skin = $Skin
@onready var actions = $Actions
@onready var skills = $Job/Skills

var target_global_position : Vector2

var selected : bool = false: set = set_selected
var selectable : bool = false

@export var party_member = false

func _ready() -> void:
	var direction : Vector2 = Vector2(-1.0, 0.0) if party_member else Vector2(1.0, 0.0)
	target_global_position = $TargetAnchor.global_position + direction * TARGET_OFFSET_DISTANCE
	
	actions.initialize(skills.get_children())
	
	stats.connect("health_depleted", Callable(self, "_on_health_depleted"))
	self.selectable = true

func play_turn(target : Battler, action):
	await skin.move_forward()
	action.execute(self, target)
	await skin.move_to(target)
	await get_tree().create_timer(1.0).timeout
	await skin.return_to_start()

func set_selected(value):
	selected = value
	skin.blink = value

func attack(target : Battler):
	var hit = Hit.new(stats.strength)
	target.take_damage(hit)

func use_skill(target : Battler, skill : CharacterSkill) -> void:
	#if stats.mana < skill.mana_cost:
		#print("no mana")
		#return
	#stats.mana -= skill.mana_cost
	var hit = Hit.new(stats.strength, skill.base_damage)
	target.take_damage(hit)

func take_damage(hit):
	stats.take_damage(hit)
	skin.play_stagger()

func _on_health_depleted():
	selectable = false
	await skin.play_death()
	if get_parent() is TurnQueue:
		get_parent().remove_child(self)
	queue_free()

func appear():
	var offset_direction = 1.0 if party_member else -1.0
	skin.position.x += TARGET_OFFSET_DISTANCE * offset_direction
	skin.appear()

func choose_target(targets : Array):
	"""if this cha"""
	var random_hit = randf()

	var target_min_health = targets[randi() % len(targets)]
	
	if random_hit > target_lowest_health_chance:
		print("random hit")
		return target_min_health
	
	var min_health = target_min_health.stats.health 
	for target in targets:
		if target.stats.health < min_health:
			target_min_health = target
	return target_min_health

func get_portrait() -> Texture2D:
	return skin.get_portrait()


func choose_skill() -> CombatAction:
	var skills = actions.get_children()
	return skills[randi() % skills.size()]
