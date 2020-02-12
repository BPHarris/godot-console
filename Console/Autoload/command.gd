"""Godot Console Command

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
var description : String
var help : String


func _init(name: String, parent_node: Node, function_name: String, description: String = '', help: String = ''):
	self.command_name = name
	self.parent_node = parent_node
	self.function_name = function_name
	self.description = description
	self.help = help
