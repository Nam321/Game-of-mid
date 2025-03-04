extends Node2D

@onready var bar = $Column/TextureProgressBar
@onready var label = $Column/LifeLabel

var max_health = 0: set = set_max_health
var health = 0: set = set_health

@export var LABEL_ABOVE : bool

func _ready():
	if LABEL_ABOVE:
		label.raise()

func set_max_health(value):
	max_health = value
	bar.max_value = value
	label.display(health, max_health)

func set_health(value):
	health = value
	bar.value = value
	label.display(health, max_health)

func initialize(battler : Battler):
	var lifebar_anchor = battler.lifebar_anchor
	global_position = lifebar_anchor.global_position
	lifebar_anchor.remote_path = lifebar_anchor.get_path_to(self)
	
	var health_node = battler.stats
	health_node.connect("health_changed", Callable(self, "_on_Battler_health_changed"))
	health_node.connect("health_depleted", Callable(self, "_on_Battler_health_depleted"))
	
	self.health = health_node.health
	self.max_health = health_node.max_health

func _on_Battler_health_changed(new_health):
	self.health = new_health
	
func _on_Battler_health_depleted():
	hide()
