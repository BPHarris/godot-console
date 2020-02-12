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


var commands := {}


onready var output := $container/output
onready var input := $container/input


func _ready() -> void:
	pass


func _on_input_text_entered(new_text: String) -> void:
	"""TODO: Auto-generate stub."""
	pass
