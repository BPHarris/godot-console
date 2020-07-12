"""Godot Console Command Argument Types

Argument Types:
	- TYPE_NIL
	- TYPE_BOOL
	- TYPE_INT
	- TYPE_REAL
	- TYPE_STRING

Typing Rules:
	Types A, B are equivalent if A == B
	Types A, B are equivalent if A == TYPE_NIL (dynamic)
		i.e. Type T is TYPE_NIL/dynamic, but TYPE_NIL/dynamic is not always T

Todo:
	- get_type(string)
	- is_type(string, CommandArgumentType)
	- support for TYPE_OBJECT? (for Nodes) - is there a better way?

"""

extends Node
class_name Types


const supported_types := {
	TYPE_NIL        : "Variant",
	TYPE_BOOL       : "bool",
	TYPE_INT        : "int",
	TYPE_REAL       : "float",
	TYPE_STRING     : "String",
	TYPE_NODE_PATH  : "NodePath",
}


static func is_supported(type : int) -> bool:
	"""Return true if the given type is supported, false otherwise."""
	return type in supported_types


static func get_type_name(type : int) -> String:
	"""Return the name of the given type."""
	return supported_types.get(type, "unsupported_type")


static func get_value(string : String):
	"""Return the value represented by the given string."""
	# Boolean
	if string == "true":
		return true
	if string == "false":
		return false
	
	# Int
	if string.is_valid_integer():
		return int(string)
	
	# Float/Real
	if string.is_valid_float():
		return float(string)
	
	# The empty string
	if string == "":
		return string
	
	# Node reference
	if string[0] == "@":
		return NodePath(string.substr(1))
	
	# Short/long-string or other
	return string


static func get_type(value) -> int:
	"""Return the type of the given value."""
	return typeof(value)


static func get_value_and_type(string : String) -> Array:
	"""Return the value represented by the given string and it's type."""
	var value = get_value(string)
	return [value, get_type(value)]


static func equivalent(type_a : int, type_b : int) -> bool:
	"""Return true if two types are equivalent. See __doc__ for typing rules."""
	if type_a == TYPE_NIL:
		return true
	return type_a == type_b
