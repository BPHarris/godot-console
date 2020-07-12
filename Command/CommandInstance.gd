"""Godot Console Command Instance

To be returned by the CommandParser. Stores refence to status (OK/Error),
command name, and arguments.

CommandInstance.new(NAME, ARGUMENTS) => A CommandInstance for the command
	of the given name with the given arguments
CommandParser.error(ERROR_CODE, ERROR_MESSAGE) => A CommandInstance for
	an invalid command with the given error code and message

ERROR_CODE referes to member of the @GlobalScope.Error enum.

"""

extends Node
class_name CommandInstance


var status : int = OK
var error_message : String = ""

var command_name : String
var command_arguments : Array


func _init(command_name : String = "", command_arguments : Array = []) -> void:
	self.command_name = command_name
	self.command_arguments = command_arguments
