extends CanvasLayer

@onready var resume_btn = $ColorRect/VBoxContainer/Continue
@onready var save_btn = $ColorRect/VBoxContainer/Save
@onready var quit_btn = $ColorRect/VBoxContainer/Quit

func _ready():
	visible = false
	resume_btn.pressed.connect(unpause)
	quit_btn.pressed.connect(quit)

func _input(event):
	if event.is_action_pressed("pause"):
		if visible:
			unpause()
		else:
			pause()

func pause():
	get_tree().paused = true
	visible = true
	resume_btn.grab_focus()

func unpause():
	get_tree().paused = false
	visible = false


func quit():
	get_tree().paused = false
	get_tree().quit()
