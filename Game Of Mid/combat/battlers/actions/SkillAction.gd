extends CombatAction

var skill_to_use : CharacterSkill
var _rng = RandomNumberGenerator.new()

func _ready() -> void:
	name = skill_to_use.name
	_rng.randomize()

func execute(actor : Battler, target : Battler) -> void:
	var success = false
	
	if skill_to_use.success_chance >= 1.0:
		success = true
	else:
		success = _rng.randf() < skill_to_use.success_chance

	if success:
		print("Skill succeeded: ", skill_to_use.name)
		actor.use_skill(target, skill_to_use)
	else:
		print("Skill missed: ", skill_to_use.name)
		await actor.skin.anim.animation_finished

	emit_signal("execute_finished")
