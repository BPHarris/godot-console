"""Godot Console Response Type

Stores the response of a console command, to be returned by console command
functions.

Usage:
	- Not for user use (excluding modifications)

Developer Notes:
	- 

Todo:
	- 

"""

extends Node
class_name CommandResponse


enum ResponseType { EMPTY, ERROR, RESULT }


var type    # type : ResponseType
var text    # type : String


func _init(type := ResponseType.EMPTY, text : String = "") -> void:
	self.type = type
	self.text = text


func get_response() -> String:
	"""Return the printable response text."""
	if self.type == ResponseType.ERROR:
		return "[b][color=red]Error[/color][/b]: " + self.text
	if self.type == ResponseType.RESULT:
		return self.text
	return ""
