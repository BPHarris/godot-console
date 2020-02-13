"""Godot Console Response Type

Stores the response of a console command, to be returned by console command
functions.

Usage:
	- Include this script as an Autoload script.

Developer Notes:
	- 

Todo:
	- 

"""

extends Node
class_name CommandResponse


enum ResponseType { EMPTY, ERROR, RESULT }


var type # type: ResponseType
var text : String


func _init(type = ResponseType.EMPTY, text: String = '') -> void:
	self.type = type
	self.text = text


func get_response() -> String:
	"""Return the printable response text."""
	# If it is an EMPTY respose, return nothing
	if type == ResponseType.EMPTY:
		return ''
	
	# If it is an ERROR, prefix 'error'
	if type == ResponseType.ERROR:
		return '[color=red]error[/color]: {text}'.format({'text': text})
	
	# If it is a RESULT, prefix 'result'
	if type == ResponseType.RESULT:
		return '{text}'.format({'text': text})
	return ''
