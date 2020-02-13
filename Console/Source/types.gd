"""Godot Console Command Argument Types

Argument Types:
	- TYPE_INT
	- TYPE_STRING
	- TYPE_REAL
	- TYPE_BOOL

Todo:
	- get_type(string)
	- is_type(string, CommandArgumentType)

"""

extends Node
class_name ConsoleTypes

var supported_types := {
	TYPE_INT    : 'int',
	TYPE_REAL   : 'real',
	TYPE_STRING : 'string',
	TYPE_BOOL   : 'bool'
}


func is_supported(type) -> bool:
	return type in supported_types


func get_type_name(type) -> String:
	return supported_types.get(type, 'unsupported_type')
