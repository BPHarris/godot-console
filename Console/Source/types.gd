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


func get_type_name(type):
	if type == TYPE_INT:
		return 'int'
	if type == TYPE_STRING:
		return 'string'
	if type == TYPE_REAL:
		return 'real'
	if type == TYPE_BOOL:
		return 'bool'
	return 'unsuported'
