"""Godot Console

Usage:
	- 

Developer Notes:
	- 

Todo:
	- allow disable defualt commands via exprt var
	- allow string arguments
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


var commands := {}
var console_output_text := ''

onready var types := ConsoleTypes.new()

onready var output := $container/output
onready var input := $container/input


func _ready() -> void:
	# Set output scroll follow and disable output selection
	output.set_scroll_follow(true)
	output.set_focus_mode(FOCUS_NONE)
	
	# Set initial visibility
	visible = false
	if open_on_start:
		visible = true
	
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


func add_command(command_name: String, parent_node: Node, function_name: String = '', command_arguments: Array = [], description: String = '', help: String = '') -> void:
	"""Add the given command to the console's repertoire."""
	if not function_name:
		function_name = command_name
	
	# Check arguments are of legal types
	for argument in command_arguments:
		if not argument[1] in types.supported_types:
			write_error('couldn\'t add command \'%s\', argument \'%s\' of invalid type', [command_name, argument[0]])
			return
	
	# Check target exists
	if not parent_node.has_method(function_name):
		write_error('couldn\'t add command \'%s\', target method \'%s.%s\' doesn\'t exist', [command_name, parent_node.name, function_name])
		return
	
	if not description:
		description = 'no description given'
	
	if not help:
		help = 'usage:  {pattern}  --  {description}'
	
	# Get usage pattern
	var pattern := command_name
	for argument in command_arguments:
		pattern += ' <{argument_type}: {argument_name}>'.format(
			{'argument_type': types.get_type_name(argument[1]), 'argument_name': argument[0]}
		)
	
	help = help.format({'pattern': pattern, 'description': description})
	
	commands[command_name] = Command.new(command_name, parent_node, function_name, command_arguments, description, help)


func write(string: String, substitutions = []) -> void:
	"""Write the given string to the console."""
	var coloured_substitutions := []
	for sub in substitutions:
		coloured_substitutions.append('[color=blue]' + sub + '[/color]')
	
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


func _on_input_text_entered(new_text: String) -> void:
	"""TODO: Auto-generated stub."""
	pass


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
		return CommandResponse.new(CommandResponse.ResponseType.ERROR, 'no command %s' % command_name)
	
	return CommandResponse.new(CommandResponse.ResponseType.RESULT, '%s\n%s' % [command.description, command.help])


func _command_exit() -> CommandResponse:
	"""Faux-close the current console instance."""
	self.visible = false
	return _command_clear()


func _command_quit() -> CommandResponse:
	"""Quit the game."""
	get_tree().quit()
	return CommandResponse.new()
