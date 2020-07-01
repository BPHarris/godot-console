"""Godot Console

Console Command Mini Language:
	command			::= [a-zA-Z_]+
	
	arguments		::= (' ' argument)+
	argument		::= 'true'          ; bool
					|	'false'         ; bool
					|	[0-9]+          ; int
					|	[0-9]+.[0-9]+   ; float
					|	[a-zA-Z]+       ; small string/name
					|	'"' [c]+ '"'    ; long string, for any character c
					|	'$' [a-zA-Z.]+  ; node reference
	
	command_line	::= command arguments?

Author: Brandon Harris (bpharris@pm.me)

Nota Bene:
	This requires a Globals singleton to exist in your project, with the field
	'console_commands' and type Dictionary.

Usage:
	- Ensure all input elsewhere is handled with _unhandled_input, or else
	  entering input into the console may move your player charcter, etc.
	- Add a new console node to the player character (or other persistent
	  singleton). This is done the same was as adding any new child node.
	- Set the 'Layout' of the 'Console' node and it's parent's to 'Full Rect'.

Developer Notes:
	- 

Todo:
	- history
	- tab completion

"""

tool
extends Control


# Signals
signal console_opened
signal console_closed


# Console key bindings
export(String) var input_action_toggle_console := 'dev_toggle_console'
export(String) var input_action_exit_console := 'ui_cancel'
export(String) var input_action_history_up := 'ui_up'
export(String) var input_action_history_down := 'ui_down'

# Console settings
export(bool) var log_command_on_entry := true
export(bool) var log_command_parse_error := true
export(bool) var log_command_type_on_entry := false
export(bool) var log_command_registration_error := true
export(bool) var log_command_registration_success := false


onready var _console_scene := preload('res://addons/godot_console/Console/Console.tscn')
onready var _output : RichTextLabel
onready var _input : LineEdit

onready var history_pointer := 0
onready var command_history := []

onready var _open_mouse_mode := Input.MOUSE_MODE_VISIBLE
onready var _closed_mouse_mode := Input.get_mouse_mode()


func _ready() -> void:
	"""On ready, instance a new console and register the input/output fields."""
	pause_mode = PAUSE_MODE_PROCESS
	
	var _console_scene_instance := _console_scene.instance()
	add_child(_console_scene_instance, true)
	
	# Register the input/output fields
	_output = _console_scene_instance.get_node('Output')
	_input = _console_scene_instance.get_node('Input')
	
	# Disable focusing on output instead of input line
	_output.set_focus_mode(FOCUS_NONE)
	
	_input.connect('text_entered', self, '_on_text_entered')
	
	if visible:
		_input.grab_focus()
		Input.set_mouse_mode(_open_mouse_mode)
		emit_signal('console_opened')
	
	_add_default_commands()


func _add_default_commands() -> void:
	"""Add the console's default commands."""
	add_command('clear', self, '_command_clear', [], 'clear the console output')
	
	add_command(
		'help', self, '_command_help',
		[['command_name', TYPE_STRING]],
		'display the given command\'s help message'
	)
	
	add_command(
		'exit', self, '_command_exit', [], 'exit the current console session')
	
	add_command('quit', self, '_command_quit', [], 'quit the game')
	
	add_command(
		'echo', self, '_command_echo',
		[['output', TYPE_NIL]],
		'echo the given argument'
	)
	
	add_command(
		'print_tree', self, '_command_print_tree', [], 'print the scene tree')
	
	add_command(
		'print_children', self, '_command_print_children',
		[['node', TYPE_NODE_PATH]],
		'recursively print the given node\'s children'
	)
	
	add_command('list', self, '_command_list', [], 'list registered commands')


func _physics_process(delta) -> void:
	"""Handle input here (not _input) or else a backtick appears on re-open."""
	# Toggle console
	if Input.is_action_just_pressed(input_action_toggle_console):
		_on_toggle_console()

	# If the console is visible, escape/ui_cancel will close it
	if Input.is_action_just_pressed(input_action_exit_console) and visible:
		visible = false


func add_command(
	name : String,
	parent_node : Node,
	method_name : String = '',
	command_arguments : Array = [],  # Array[Array[name : String, type : Type]]
	description : String = '',
	help : String = ''               # By default, help message is auto-generated
) -> int:
	"""Add the given command to the console's repertoire.
	
	Return error code from @GlobalScope.Error:
		ERR_METHOD_NOT_FOUND - if parent_node has no method method_name
		ERR_ALREADY_IN_USE - if console command with given name already registered
		OK - if successful
	
	"""
	if not method_name:
		method_name = name
	
	# TODO: Check argument types are legal
	
	# Check target exists
	if not parent_node.has_method(method_name):
		if log_command_registration_error:
			write_error(
				ERR_METHOD_NOT_FOUND,
				'couldn\'t add command \'%s\', method \'%s.%s\' not found'
				% [name, parent_node.name, method_name]
			)
		return ERR_METHOD_NOT_FOUND
	
	# Check name is free in environment
	if Globals.console_commands.get(name):
		if log_command_registration_error:
			write_error(ERR_ALREADY_IN_USE, 'command name \'%s\' already in use' % name)
		return ERR_ALREADY_IN_USE
	
	# Register command
	Globals.console_commands[name] = Command.new(
		name, parent_node, method_name, command_arguments, description, help)
	
	if log_command_registration_success:
		write('Registered command \'%s\'' % name)
	return OK


func write(text : String, prefix : String = '\n', suffix : String = '') -> int:
	"""Write to the console. Return error code."""
	return _output.append_bbcode(prefix + text + suffix)


func write_error(error_code : int, error_message : String) -> int:
	"""Write the given text with an error prefix. Return error code."""
	
	# Get the error code prefix in red text
	var error_code_prefix := ''
	match error_code:
		ERR_PARSE_ERROR:
			error_code_prefix = 'ParseError'
		ERR_INVALID_DATA:
			error_code_prefix = 'InvalidDataError'
		ERR_ALREADY_IN_USE:
			error_code_prefix = 'AleadyInUseError'
		ERR_ALREADY_EXISTS:
			error_code_prefix = 'AleadyExistsError'
		ERR_DOES_NOT_EXIST:
			error_code_prefix = 'DoesNotExistError'
		ERR_METHOD_NOT_FOUND:
			error_code_prefix = 'MethodNotFoundError'
		ERR_PARAMETER_RANGE_ERROR:
			error_code_prefix = 'ParameterRangeError'
		_:
			error_code_prefix = 'Error'
	error_code_prefix = '[b][color=red]%s: [/color][/b]' % error_code_prefix
	
	return write(error_code_prefix + error_message)


func response_empty() -> CommandResponse:
	"""Short-hand for the empty response."""
	return CommandResponse.new()


func response_error(error_message : String) -> CommandResponse:
	"""Short-hand for an error response."""
	return CommandResponse.new(CommandResponse.ResponseType.ERROR, error_message)


func response_result(result : String) -> CommandResponse:
	"""Short-hand for a standard result."""
	return CommandResponse.new(CommandResponse.ResponseType.RESULT, result)


func _on_text_entered(text: String) -> int:
	"""Handle user text entry."""
	_input.clear()
	history_pointer = 0
	
	# Add to history if history is empty or text is not equal to the previous entry
	if not command_history or command_history[len(command_history) - 1] != text:
		command_history.append(text)
	
	if log_command_on_entry:
		write('> ' + text)
	
	var command_instance := CommandParser.parse_command_line(text)
	
	# If parse error occured, abort
	if command_instance.status != OK:
		if log_command_parse_error:
			return write_error(command_instance.status, command_instance.error_message)
		return OK
	
	# Get command
	var command : Command = Globals.console_commands.get(command_instance.command_name)
	if command == null:
		return write_error(
			ERR_DOES_NOT_EXIST,
			'command "%s" not found' % command_instance.command_name
		)
	
	# Log command arguments types
	if log_command_type_on_entry and command_instance.status == OK:
		write(command_instance.command_name)
		for a in command_instance.command_arguments:
			var format = '["%s", %s]' if typeof(a[0]) == TYPE_STRING else '[%s, %s]'
			write(format % [a[0], Types.get_type_name(a[1])], ' ')
	
	var result := command.execute(command_instance.command_arguments)
	if result:
		return write(result.get_response())
	
	# Something went wrong, try to work out why
	if len(command_instance.command_arguments) > len(command.command_arguments):
		return write_error(
			ERR_PARAMETER_RANGE_ERROR,
			'too many arguments for command "%s"' % [command_instance.command_name]
		)
	if len(command_instance.command_arguments) < len(command.command_arguments):
		return write_error(
			ERR_PARAMETER_RANGE_ERROR,
			'too few arguments for command "%s"' % [command_instance.command_name]
		)
	for i in len(command_instance.command_arguments):
		var expected_type : int = command.command_arguments[i][1]
		var received_type : int = command_instance.command_arguments[i][1]
		
		if not Types.equivalent(expected_type, received_type):
			var e := 'expected argument "%s" of type [color=blue]%s[/color], ' \
			       + 'received "%s" of type [color=blue]%s[/color]'
			
			var format_data = [
				command.command_arguments[i][0],
				Types.get_type_name(expected_type),
				command_instance.command_arguments[i][0],
				Types.get_type_name(received_type)
			]
			
			return write_error(ERR_INVALID_DATA, e % format_data)
	
	return write_error(FAILED, 'an unexpected error occurred')


func _on_toggle_console() -> void:
	"""Toggle visibility, handle mouse mode, emit signal, and clear input."""
	if not visible:
		_closed_mouse_mode = Input.get_mouse_mode()
	
	visible = !visible
	
	if visible:
		_input.grab_focus()
	
	Input.set_mouse_mode(_open_mouse_mode if visible else _closed_mouse_mode)
	emit_signal('console_opened' if visible else 'console_closed')
	
	_input.clear()
	history_pointer = 0


func _command_clear() -> CommandResponse:
	"""Clear the console."""
	_input.clear()
	_output.clear()
	return response_empty()


func _command_help(command_name: String = 'help') -> CommandResponse:
	"""Display the commands help string."""
	var command : Command = Globals.console_commands.get(command_name)
	
	# If no such command, return error
	if not command:
		return response_error('no command \'[color=green]%s[/color]\'' % command_name)
	
	return response_result(command.help)


func _command_exit() -> CommandResponse:
	"""Faux-close the current console instance."""
	self.visible = false
	return _command_clear()


func _command_quit() -> CommandResponse:
	"""Quit the game."""
	get_tree().quit()
	return response_empty()


func _command_echo(output) -> CommandResponse:
	"""Echo the output string."""
	return response_result(str(output))


func _command_print_tree() -> CommandResponse:
	"""Print the scene tree."""
	return _command_print_children(NodePath("/root"))


func _command_print_children(start_node_path : NodePath) -> CommandResponse:
	"""Print the children of a node."""
	var start_node := get_node_or_null(start_node_path)
	
	if not start_node:
		var path_string := '"%s"' % start_node_path
		if not start_node_path.is_absolute():
			path_string = '"%s/%s"' % [get_path(), start_node_path]
		return response_error('no such node %s' % [path_string])
	
	return response_result(_helper_get_node_children_tree(start_node))


func _helper_get_node_children_tree(node : Node, indent_level : int = 0) -> String:
	"""Recursively get the node's children as a tree."""
	var output := _helper_get_indent(indent_level) + node.name + '\n'
	
	for child in node.get_children():
		output += _helper_get_node_children_tree(child, indent_level + 1)
	
	return output


func _helper_get_indent(indent_level : int) -> String:
	"""Return the indentation at the given indentation level."""
	var output := ''
	for i in range(indent_level):
		output += '  '
	return output


func _command_list() -> CommandResponse:
	"""Print the list of all commands."""
	var commands := Globals.console_commands
	
	if len(commands) == 0:
		return response_error('can\'t access Globals.console_commands')
	
	var commands_list : String = ''
	
	for command_name in commands:
		commands_list += commands[command_name].name + '\t'
	
	return response_result(commands_list)
