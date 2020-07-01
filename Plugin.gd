"""Godot Console Editor Plugin"""

tool
extends EditorPlugin


func _enter_tree():
	"""On plugin activation, notify user."""
	name = 'ConsolePlugin'
	add_custom_type('Console', 'Control', preload('Console.gd'), preload('icon16.png'))
	
	print('Godot Console plugin activated.')


func _exit_tree():
	"""On plugin deactivation, notify user."""
	remove_custom_type('Console')
	
	print('Godot Console plugin deactivated.')
