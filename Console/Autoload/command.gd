"""Godot Console Command

Arguments Format:
	[[name_0, type_0], ..., [name_i, type_i]] foreach argument 0..i
	where each type_n is valid (see command_argument_types.gd),
	and each name_n is a string.

Developer Notes:
	- 

Todo:
	- 

"""

extends Node
class_name Command


var command_name : String
var parent_node : Node
var function_name : String
var command_arguments : Array
var description : String
var help : String


func _init(name: String, parent_node: Node, function_name: String, command_arguments: Array, description: String = '', help: String = ''):
	self.command_name = name
	self.parent_node = parent_node
	self.function_name = function_name
	self.command_arguments = command_arguments
	self.description = description
	self.help = help
