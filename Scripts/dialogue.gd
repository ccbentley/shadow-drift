extends CanvasLayer

const CHAR_READ_RATE = 0.05

@onready var textbox_container = $TextboxContainer
@onready var start_symbol = $TextboxContainer/MarginContainer/HBoxContainer/Start
@onready var end_symbol = $TextboxContainer/MarginContainer/HBoxContainer/End
@onready var label = $TextboxContainer/MarginContainer/HBoxContainer/Label
var tween : Tween

@onready var player = $"../Player"

enum State
{
	READY,
	READING,
	FINISHED
}

var current_state = State.READY
var text_queue = []

func _ready():
	hide_textbox()

func _process(_delta):
	match current_state:
		State.READY:
			if(!text_queue.is_empty()):
				display_text()
		State.READING:
			if(Input.is_action_just_pressed("ui_accept")):
				label.visible_ratio = 1.0
				tween.kill()
				end_symbol.text = "<-"
				change_state(State.FINISHED)
		State.FINISHED:
			if(Input.is_action_just_pressed("ui_accept")):
				change_state(State.READY)
				hide_textbox()

func queue_text(next_text):
	text_queue.push_back(next_text)
	
func clear_queue():
	text_queue.clear()
	change_state(State.READY)

func hide_textbox():
	start_symbol.text = ""
	end_symbol.text = ""
	label.text = ""
	textbox_container.hide()
	player.enable_movement()
	
func show_textbox():
	start_symbol.text = "*"
	textbox_container.show()
	player.disable_movement()

func display_text():
	tween = get_tree().create_tween()
	var next_text = text_queue.pop_front()
	label.text = next_text
	label.visible_characters = 0.0
	change_state(State.READING)
	show_textbox()
	tween.tween_property(label, "visible_characters", len(next_text), len(next_text) * CHAR_READ_RATE).from(0)
	tween.connect("finished", on_tween_finished)

func on_tween_finished():
	end_symbol.text = "<-"
	change_state(State.FINISHED)

func change_state(next_state):
	current_state = next_state
	match current_state:
		State.READY:
			pass
		State.READING:
			pass
		State.FINISHED:
			pass
