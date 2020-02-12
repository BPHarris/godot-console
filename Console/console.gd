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

export(int) var font_size = 24


var commands := {}
var console_output_text := ''


onready var output := $container/output
onready var input := $container/input


func _ready() -> void:
	# Set resize handler
	get_tree().connect("screen_resized", self, "_on_screen_resized")
	
	# Set console size
	_on_screen_resized()


func _process(delta):
	# Make the console output text monospace at all times
	self.output.bbcode_text = '[code]{text}[/code]'.format({'text': self.console_output_text})


func _on_input_text_entered(new_text: String) -> void:
	"""TODO: Auto-generated stub."""
	pass


func _on_screen_resized():
	"""Resize the console to full-screen, with the input at the bottom."""
	var window := get_viewport().size
	
	# Set output size and position
	self.output.set_begin(Vector2())
	self.output.set_end(Vector2(window.x, window.y - self.font_size))
	print('output: ', self.output.get_begin(), ', ', self.output.get_end())
	
	# Set input size and position
	self.input.set_begin(Vector2(0, window.y - self.font_size))
	self.input.set_end(Vector2(window.x, self.font_size))
	print('input: ', self.input.get_begin(), ', ', self.input.get_end())
