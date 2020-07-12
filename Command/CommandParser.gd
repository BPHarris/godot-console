"""Godot Console Command Parser

Console Command Mini Language:
	command         ::= [a-zA-Z_-.]+
	
	arguments       ::= (' ' argument)+
	argument        ::= 'true'              ; bool
					|	'false'             ; bool
					|	[0-9]+              ; int
					|	[0-9]+ '.' [0-9]+   ; float/real
					|	[c]+                ; small string/name
					|	'"' [c]+ '"'        ; long string
					|	'@' [c]+            ; node path
		where c is short-hand for any character
	
	command_line    ::= command arguments?

Developer Notes:
	- 

Todo:
	- allow 0-9 in command FOLLOW_SET
		i.e. command ::= [a-zA-Z_][a-zA-Z_-.0-9]+

"""

extends Node
class_name CommandParser


const alphabetic := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
const numeric := "0123456789"
const special := "_-."


static func parse_command_line(command_line : String) -> CommandInstance:
	"""Parse the given command line following the grammar specification.
	
	command_line ::= command arguments?
	"""
	var command := parse_command(command_line)
	if command.status != OK:
		return parser_error(command.status, command.error_message)

	var arguments := parse_arguments(command.data[1])
	if arguments.status != OK:
		return parser_error(arguments.status, arguments.error_message)

	return CommandInstance.new(command.data[0], arguments.data)


static func parse_command(command_line : String) -> ErrorOrData:
	"""Parse the command from the command line.
	
	command ::= [a-zA-Z_-.]+
	
	Return:
		ErrorOrData[command, remainder] if no parse error,
		otherwise, return ErrorOrData(ERR_PARSE_ERROR)
	"""
	var command := ""
	var remainder := ""
	
	for i in range(len(command_line)):
		if command_line[i] in alphabetic:
			command += command_line[i]
			continue
		if command_line[i] in special:
			command += command_line[i]
			continue
		if command_line[i] == " ":
			remainder = command_line.substr(i)
			break
		return error(
			ERR_PARSE_ERROR,
			"illegal character '%s' in command name; expected a letter, '_', '-', or '.'"
				% command_line[i]
		)
	
	return data([command, remainder])


static func parse_arguments(command_line) -> ErrorOrData:
	"""Parse the arguments from the command line.
	
	Return:
		ErrorOrData[Argument_1, ..., Argument_n] if no parse error,
		otherwise, return ErrorOrData(ERR_PARSE_ERROR).
	"""
	if not command_line:
		return data([])
	
	var arguments := []
	
	while command_line:
		# Consume SPACE
		if command_line[0] != " ":
			return error(ERR_PARSE_ERROR, "expected space before command argument")
		command_line = command_line.substr(1)
		
		# Catch empty argument
		if not command_line:
			return error(ERR_PARSE_ERROR, "expected argument after space")
		
		# Skip whitespace
		while command_line[0] == " ":
			if command_line == " ":
				return error(ERR_PARSE_ERROR, "trailing whitespace")
			command_line = command_line.substr(1)
		
		var command_break_char := " "
		
		# Consume argument
		var argument_string := ""
		
		# Long-string
		if command_line[0] == '"':
			command_break_char = '"'
			command_line = command_line.substr(1)
		
		# FIXME: Yuck! Fix this shit.
		var last_i := 0
		for i in range(len(command_line)):
			last_i = i
			
			# Check for illegal "
			if command_line[i] == '"' and command_break_char == " ":
				return error(ERR_PARSE_ERROR, 'unexpected " in argument')
			
			if command_line[i] == command_break_char:
				if command_break_char == " ":
					last_i -= 1
				break
			argument_string += command_line[i]
		command_line = command_line.substr(last_i + 1)
		
		# Parse the individual argument
		arguments.append(parse_argument(argument_string).data)
	
	return data(arguments)


static func parse_argument(argument_string) -> ErrorOrData:
	"""Parse the first agrument in the command line.
	
	Return:
		ErrorOrData[Argument_n, remainder_of_line] if no parse error,
		otherwise, return ErrorOrData(ERR_PARSE_ERROR).
	"""
	return data(Types.get_value_and_type(argument_string))


static func error(status : int, error_message : String) -> ErrorOrData:
	"""Return a new ErrorOrData(status, error_message)."""
	var return_value = ErrorOrData.new()
	
	return_value.status = status
	return_value.error_message = error_message
	
	return return_value


static func data(data : Array) -> ErrorOrData:
	"""Return a new ErrorOrData(status = OK, data)."""
	var return_value = ErrorOrData.new()
	
	return_value.status = OK
	return_value.data = data
	
	return return_value


static func parser_error(status : int, error_message : String) -> CommandInstance:
	"""Return a new CommandInstance with the given status and error message."""
	var command_instance := CommandInstance.new()
	
	command_instance.status = status
	command_instance.error_message = error_message
	
	return command_instance
