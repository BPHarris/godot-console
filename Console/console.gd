"""Godot Console

Console Command Mini Language:
	command         ::= [a-zA-Z_]+
	
	arguments       ::= (' ' argument)+
	argument        ::= 'true'          ; bool
					|	'false'         ; bool
					|	[0-9]+          ; int
					|	[0-9]+.[0-9]+   ; float
					|	[a-zA-Z]+       ; small string/name
					|	'"' [c]+ '"'    ; long string, for any character c
					|	'$' [a-zA-Z.]+  ; node reference
	
	command_line    ::= command arguments?

Usage:
	- 

Developer Notes:
	- 

Todo:
	- fix 'Class 'CommandArgumentType' could not be fully loaded (script error or cyclic dependenct).'
	- tab completion
	- better help messages
	- refactor

"""

extends Control
class_name Console

# Console key bindings
export(String) var input_action_toggle_console := 'dev_toggle_console'
export(String) var input_action_exit_console := 'ui_cancel'
export(String) var input_action_history_up := 'ui_up'
export(String) var input_action_history_down := 'ui_down'

export(bool) var open_on_start := true

# Enable default commands?
export(bool) var enable_command_clear := true
export(bool) var enable_command_help := true
export(bool) var enable_command_exit := true
export(bool) var enable_command_quit := true
export(bool) var enable_command_echo := true


var commands := {}
var console_output_text := ''

onready var types := CommandArgumentType.new()
onready var parser := CommandParser.new()

onready var output := $container/output
onready var input := $container/input


func _ready() -> void:
	# Set output scroll follow and disable output selection
	output.set_scroll_follow(true)
	output.set_focus_mode(FOCUS_NONE)
	
	# Set initial visibility
	visible = false
	if open_on_start:
		_on_toggle_console()
	
	_add_default_commands()


func _add_default_commands() -> void:
	"""Add the default commands to the console's repertoire."""
	if enable_command_clear:
		add_command('clear', self, '_command_clear', [], 'clear the console output')
	
	if enable_command_help:
		add_command(
			'help',
			self, '_command_help', [['command_name', TYPE_STRING]],
			'display a commands help message and usage'
		)
	
	if enable_command_exit:
		add_command('exit', self, '_command_exit', [], 'exit the current console session')
	
	if enable_command_quit:
		add_command('quit', self, '_command_quit', [], 'quit the game')
	
	if enable_command_echo:
		add_command('echo', self, '_command_echo', [['output', null]], 'echo a string')


func add_command(command_name: String, parent_node: Node, function_name: String = '', command_arguments: Array = [], description: String = '', help: String = '') -> void:
	"""Add the given command to the console's repertoire."""
	if not function_name:
		function_name = command_name
	
	# Check arguments are of legal types
	for argument in command_arguments:
		if not types.is_supported(argument[1]):
			write_error('couldn\'t add command \'%s\', argument \'%s\' of invalid type', [command_name, argument[0]])
			return
	
	# Check target exists
	if not parent_node.has_method(function_name):
		write_error('couldn\'t add command \'%s\', target method \'%s.%s\' doesn\'t exist', [command_name, parent_node.name, function_name])
		return
	
	if not description:
		description = 'no description given'
	
	if not help:
		help = '[color=yellow]usage[/color]:  {pattern}  --  {description}'
	
	# Get usage pattern
	var pattern := '[color=blue]' + command_name + '[/color]'
	for argument in command_arguments:
		pattern += ' <[color=black]{argument_type}[/color]: {argument_name}>'.format(
			{'argument_type': types.get_type_name(argument[1]), 'argument_name': argument[0]}
		)
	
	help = help.format({'pattern': pattern, 'description': description})
	
	# Add command
	commands[command_name] = Command.new(command_name, parent_node, function_name, command_arguments, description, help)
	
	# Log addition to console
	write('added command %s to console', [command_name])
	write('\t' + help)


func write(string: String, substitutions = []) -> void:
	"""Write the given string to the console."""
	var coloured_substitutions := []
	for sub in substitutions:
		coloured_substitutions.append('[color=blue]' + str(sub) + '[/color]')
	
	console_output_text += (string % coloured_substitutions) + '\n'


func write_error(error: String, substitutions = []) -> void:
	"""Write the given error string to the console."""
	write('[color=red]error[/color]: ' + error, substitutions)


func _physics_process(delta):
	# Clear input field if not visible
	if not visible and input.text:
		input.text = ''
	
	# Toggle console
	if Input.is_action_just_pressed(input_action_toggle_console):
		_on_toggle_console()
	
	# If the console is visible, escape/ui_cancel will close it
	if Input.is_action_just_pressed(input_action_exit_console) and visible:
		visible = false
	
#	# Navigate history -- up
#	if Input.is_action_just_pressed(input_action_history_up) and command_history:
#		pass
#
#	# Navigate history -- down
#	if Input.is_action_just_pressed(input_action_history_down) and command_history:
#		pass
	
	# Make the console output text monospace at all times
	output.bbcode_text = '[code]{text}[/code]'.format({'text': console_output_text})


func _on_toggle_console() -> void:
	"""Toggle the console."""
	visible = !visible
	
	# If just set to visible, focus cursor on input
	if visible:
		input.grab_focus()


func _on_input_text_entered(command_line: String) -> void:
	"""TODO: Auto-generated stub."""
	# Clear input field
	self.input.text = ''
	
	# Add command to history
	# TODO command history
	
	# Parse command
	var command_instance := parser.parse(command_line, commands)
	if not command_instance.valid:
		write_error(command_instance.error)
		return
	
	# Get command
	var command : Command = commands.get(command_instance.command_name, null)
	if not command:
		write_error('command %s does not exist', [command_instance.command_name])
		return
	
	# Check number of arguments
	print(command_instance.command_arguments, command.command_arguments)
	if len(command_instance.command_arguments) > len(command.command_arguments):
		write_error('too many arguments for command %s', [command.command_name])
		return
	if len(command_instance.command_arguments) > len(command.command_arguments):
		write_error('too few arguments for command %s', [command.command_name])
		return
	
	# Process arguments
	var arguments : Array = []
	for i in range(len(command.command_arguments)):
		var expected = command.command_arguments[i][1]
		var received = types.get_type(command_instance.command_arguments[i])
		
		# Check type
		if not types.equivalent(expected, received):
			write_error(
				'argument ' + str(i + 1) + ' (value = %s) wrong type, expected %s and received %s',
				[
					command_instance.command_arguments[i],
					types.get_type_name(expected),
					types.get_type_name(received)
				]
			)
			return
		
		# Process
		arguments.append(types.get_value(command_instance.command_arguments[i]))
	
	print(command.command_name, ' ', arguments)
	
	# Execute command
	# NOTE result must be calculated BEFORE 'text +=' or text doesn't clear on clear command
	var response : CommandResponse = command.parent_node.callv(command.function_name, arguments)
	
	# Write result to console
	write(response.get_response())


func _command_clear() -> CommandResponse:
	"""Clear the console."""
	input.text = ''
	console_output_text = ''
	return CommandResponse.new()


func _command_help(command_name: String) -> CommandResponse:
	"""Display the commands help string."""
	# If command name, display help's help message
	if not command_name:
		return _command_help('help')
	
	var command : Command = commands.get(command_name, null)
	
	# If no such command, return error
	if not command:
		return CommandResponse.new(CommandResponse.ResponseType.ERROR, 'no command [color=blue]%s[/color]' % command_name)
	
	return CommandResponse.new(CommandResponse.ResponseType.RESULT, command.help)


func _command_exit() -> CommandResponse:
	"""Faux-close the current console instance."""
	self.visible = false
	return _command_clear()


func _command_quit() -> CommandResponse:
	"""Quit the game."""
	get_tree().quit()
	return CommandResponse.new()


func _command_echo(output: String) -> CommandResponse:
	"""Echo the output string."""
	return CommandResponse.new(CommandResponse.ResponseType.RESULT, output)
