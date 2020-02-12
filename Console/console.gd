"""Godot Console

Usage:
	- 

Developer Notes:
	- 

Todo:
	- 

"""

extends Control
class_name Console

export(int) var font_size = 24
export(float) var opacity = 0.2


var commands := {}


onready var output := $container/output
onready var input := $container/input


func _ready() -> void:
	get_tree().connect("screen_resized", self, "_on_screen_resized")
	
#	# TODO Set font sizes
#	self.input.get("custom_fonts/font").set_size(self.font_size)
#	self.output.get("custom_fonts/font").set_size(self.font_size)
	
	_on_screen_resized()


func _on_input_text_entered(new_text: String) -> void:
	"""TODO: Auto-generate stub."""
	pass


func _on_screen_resized():
	var window := get_viewport().size
	
	# Set output size and position
	self.output.set_begin(Vector2())
	self.output.set_end(Vector2(window.x, window.y - self.font_size))
	print('output: ', self.output.get_begin(), ', ', self.output.get_end())
	
	# Set input size and position
	self.input.set_begin(Vector2(0, window.y - self.font_size))
	self.input.set_end(Vector2(window.x, self.font_size))
	print('input: ', self.input.get_begin(), ', ', self.input.get_end())
