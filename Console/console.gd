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

export(int) var font_size := 24
export(String) var input_action_toggle_console := 'dev_toggle_console'
export(String) var input_action_exit_console := 'ui_cancel'
export(String) var input_action_history_up := 'ui_up'
export(String) var input_action_history_down := 'ui_down'
export(bool) var open_on_start := true


var commands := {}
var console_output_text := ''


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
	
	# Add default commands
	add_command('clear', self, '', [], 'clear the console', 'usage:\n\tclear')
	add_command('help', self, '', [], 'display a commands help message', 'usage:\n\thelp <command name>')
	add_command('exit', self, '', [], 'exit the console', 'usage:\n\texit')
	add_command('quit', self, '', [], 'quit the game', 'usage:\n\tquit')


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


func add_command(command_name: String, parent_node: Node, function_name: String = '', command_arguments: Array = [], description: String = '', help: String = '') -> void:
	if not function_name:
		function_name = command_name
	commands[command_name] = Command.new(command_name, parent_node, function_name, command_arguments, description, help)


func _on_toggle_console() -> void:
	"""Toggle the console."""
	visible = !visible
	
	# If just set to visible, focus cursor on input
	if visible:
		input.grab_focus()


func _on_input_text_entered(new_text: String) -> void:
	"""TODO: Auto-generated stub."""
	pass


func clear() -> CommandResponse:
	"""Clear the console."""
	input.text = ''
	console_output_text = ''
	return CommandResponse.new()


func help(command_name: String) -> CommandResponse:
	"""Display the commands help string."""
	# If command name, display help's help message
	if not command_name:
		return help('help')
	
	var command : Command = commands.get(command_name, null)
	
	# If no such command, return error
	if not command:
		return CommandResponse.new(CommandResponse.ResponseType.ERROR, 'no command %s' % command_name)
	
	return CommandResponse.new(CommandResponse.ResponseType.RESULT, '%s\n%s' % [command.description, command.help])


func exit() -> CommandResponse:
	"""Faux-close the current console instance."""
	self.visible = false
	return clear()


func quit() -> CommandResponse:
	"""Quit the game."""
	get_tree().quit()
	return CommandResponse.new()
