"""Godot Console Command Argument Types

Argument Types:
	- TYPE_INT
	- TYPE_STRING
	- TYPE_FLOAT
	- TYPE_NODE

Todo:
	- get_type(string)
	- is_type(string, CommandArgumentType)

"""

extends Node
class_name Types

# Command Argument Types
enum Type { TYPE_INT, TYPE_STRING, TYPE_FLOAT, TYPE_NODE }
