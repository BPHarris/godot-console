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


var parent : Node
var method_name : String
var command_arguments : Array
var description : String
var help : String


func _init(
	name : String,
	parent : Node,
	method_name : String,
	command_arguments : Array = [],
	description : String = '',
	help : String = ''
) -> void:
	"""Initialise new Command instance."""
	self.name = name
	self.parent = parent
	self.method_name = method_name
	self.command_arguments = command_arguments
	
	if not description:
		description = 'no description given'
	self.description = description
	
	if not help:
		help = _generate_help_string()
	self.help = help


func _generate_help_string() -> String:
	"""Return the commands help function.
	
	Format:
		command_name <arg : int> <other_arg : string> ... - description
	
	"""
	var help_string := '[color=green]' + self.name + '[/color]'
	
	for argument in self.command_arguments:
		var name_formatted : String = '[color=white]' + argument[0] + '[/color]'
		var type_formatted : String = '[color=blue]' + Types.get_type_name(argument[1]) + '[/color]'
		
		help_string += ' <' + name_formatted + ' : ' + type_formatted + '>'
	
	help_string += ' - ' + self.description
	
	return help_string


func execute(arguments_with_types : Array) -> CommandResponse:
	"""Execute the command and return the response."""
	
	var arguments := []
	for argument in arguments_with_types:
		arguments.append(argument[0])
	
	return parent.callv(method_name, arguments)
