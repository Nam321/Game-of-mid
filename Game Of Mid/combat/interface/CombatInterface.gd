extends CanvasLayer

@onready var lifebar_builder = $LifebarsBuilder
@onready var select_arrow = $SelectArrow
@onready var action_list = $ActionSelector/ItemList

var selected_action : CombatAction
var selected_target : Battler

func initialize(battlers : Array):
	lifebar_builder.initialize(battlers)

func select_target(selectable_battlers : Array) -> Battler:
	selected_target  = await select_arrow.select_target(selectable_battlers)
	return selected_target

func update_actions(battler : Battler) -> void:
	action_list.show()
	action_list.clear()
	for index in range(battler.actions.get_child_count()):
		var action = battler.actions.get_children()[index]
		action_list.add_item(action.name)
		action_list.set_item_metadata(index, action)
	action_list.select(0)
	action_list.emit_signal('item_selected', 0)

func _on_ItemList_item_selected(index):
	selected_action = action_list.get_item_metadata(index) as CombatAction
