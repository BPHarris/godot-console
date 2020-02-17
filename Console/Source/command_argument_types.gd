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
class_name CommandArgumentType

var supported_types : Dictionary = {
	TYPE_INT    : 'int',
	TYPE_REAL   : 'real',
	TYPE_STRING : 'string',
	TYPE_BOOL   : 'bool'
}


func is_supported(type) -> bool:
	return type in supported_types


func get_type_name(type) -> String:
	return supported_types.get(type, 'unsupported_type')


func get_value(string: String):
	# Int
	if string.is_valid_integer():
		return int(string)
	
	# Float/Real
	if string.is_valid_float():
		return float(string)
	
	# Boolean
	if string == 'true':
		return true
	if string == 'false':
		return false
	
	# String
	if string[0] == '"' and string[len(string) - 1] == '"':
		return string.substr(1, len(string) - 2)
	if string.is_valid_identifier():
		return string
	
	return string


func get_type(string: String):
	return typeof(get_value(string))
