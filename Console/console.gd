"""Godot Console

Usage:
	- 

Developer Notes:
	- 

Todo:
	- allow string arguments
	- tab completion
	- better help messages
	- refactor

"""

extends Control
class_name Console

export(int) var font_size := 24
export(String) var input_action_toggle_console := 'dev_toggle_console'
export(String) var input_action_exit_console := 'ui_cancel'
export(String) var input_action_history_up := 'ui_up'
export(String) var input_action_history_down := 'ui_down'
export(bool) var open_on_start := true


var commands := {}
var console_output_text := ''


onready var output := $container/output
onready var input := $container/input


func _ready() -> void:
	get_tree().connect('screen_resized', self, '_on_screen_resized')
	
	# Set console size
	_on_screen_resized()
	
	# Set output scroll follow and disable output selection
	output.set_scroll_follow(true)
	output.set_focus_mode(FOCUS_NONE)
	
	visible = false
	if open_on_start:
		visible = true


func _physics_process(delta):
	# Clear input field if not visible
	if not visible and input.text:
		input.text = ''
	
	# Toggle console
	if Input.is_action_just_pressed(input_action_toggle_console):
		_on_toggle_console()
	
	# If the console is visible, escape/ui_cancel will close it
	if Input.is_action_just_pressed(input_action_exit_console) and visible:
		visible = false
	
#	# Navigate history -- up
#	if Input.is_action_just_pressed(input_action_history_up) and command_history:
#		pass
#
#	# Navigate history -- down
#	if Input.is_action_just_pressed(input_action_history_down) and command_history:
#		pass
	
	# Make the console output text monospace at all times
	output.bbcode_text = '[code]{text}[/code]'.format({'text': console_output_text})


func _on_toggle_console() -> void:
	"""Toggle the console."""
	visible = !visible
	
	# If just set to visible, focus cursor on input
	if visible:
		input.grab_focus()


func _on_input_text_entered(new_text: String) -> void:
	"""TODO: Auto-generated stub."""
	pass


func _on_screen_resized():
	"""Resize the console to full-screen, with the input at the bottom."""
	var window := get_viewport().size
	
	# Set output size and position
	output.set_begin(Vector2())
	output.set_end(Vector2(window.x, window.y - font_size))
	print('output: ', output.get_begin(), ', ', output.get_end())
	
	# Set input size and position
	input.set_begin(Vector2(0, window.y - font_size))
	input.set_end(Vector2(window.x, font_size))
	print('input: ', input.get_begin(), ', ', input.get_end())
