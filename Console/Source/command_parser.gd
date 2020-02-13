"""Godot Console Command Parser

Console Command Mini Language:
	command         ::= [a-zA-Z_]+
	
	arguments       ::= (' ' argument)+
	argument        ::= 'true'          ; bool
					|	'false'         ; bool
					|	[0-9]+          ; int
					|	[0-9]+.[0-9]+   ; float/real
					|	[a-zA-Z]+       ; small string/name
					|	'"' [c]+ '"'    ; long string, for any character c
					|	'$' [a-zA-Z.]+  ; node reference
	
	command_line    ::= command arguments?

Developer Notes:
	- 

Todo:
	- 

"""

extends Node
class_name CommandParser


const alpha := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
const num := '0123456789'
const special := '._-'


class CommandInstance:
	"""A parsed instance of a command, ready to be executed."""
	var valid : bool = true
	var error : String = ''
	
	var command_name : String
	var command_arguments : Array
	
	func _init(command_name : String = '', command_arguments : Array = []):
		self.command_name = command_name
		self.command_arguments = command_arguments
	
	func invalid(error_string: String) -> CommandInstance:
		valid = false
		error = error_string
		return self


func parse(command_line: String, commands: Dictionary) -> CommandInstance:
	"""Parse the given command line into a CommandInstance."""
	var command_name := ''
	
	# Parse command name
	for i in range(len(command_line)):
		if command_line[i] in alpha + '_':
			command_name += command_line[i]
			continue
		if command_line[i] == ' ':
			command_line = command_line.substr(i + 1, len(command_line))
			break
		return CommandInstance.new().invalid('command name illformed')
	
	# Parse arguments
	var parsed = _parse_arguments(command_name, command_line, [])
	
	if not parsed.valid:
		return CommandInstance.new().invalid(parsed.error)
	
	# Process arguments
	# TODO determine argument types and compare to expected types in commands[command_name].command_arguments
	
	return parsed


func _parse_arguments(command_name, arguments: String, parsed = []) -> CommandInstance:
	"""Parse the next argument in arguments and recurse."""
	# Parse argument
	var argument := ''
	
	# Base case
	if arguments == '':
		return CommandInstance.new(command_name, parsed)

	# Parse long string
	if arguments[0] == '"':
		argument += arguments[0]
		for i in range(1, len(arguments)):
			argument += arguments[i]

			if arguments[i] == '"':
				# If EOL, return parsed args
				if i == len(arguments) - 1:
					return CommandInstance.new(command_name, parsed + [argument])
				
				# Parse space
				if arguments[i + 1] != ' ':
					return CommandInstance.new().invalid('missing space after long string argument')
				
				# If space then EOL, return parsed args
				if i == len(arguments):
					return CommandInstance.new(command_name, parsed + [argument])
				
				# Parse remaining args
				return _parse_arguments(command_name, arguments.substr(i + 2, len(arguments)), parsed + [argument])
		return CommandInstance.new().invalid('argument missing closing "')

	# Parse other
	for i in range(len(arguments)):
		if arguments[i] == ' ':
			# If EOL, return parsed args
			if i == len(arguments) - 1:
				return CommandInstance.new(command_name, parsed + [argument])
			
			# Parse remaining args
			return _parse_arguments(command_name, arguments.substr(i + 1, len(arguments)), parsed + [argument])
		argument += arguments[i]

	# Reached EOF without space
	if argument:
		return CommandInstance.new(command_name, parsed + [argument])

	return CommandInstance.new().invalid('argument empty')
