"""Godot Console Command Parser

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

Developer Notes:
	- 

Todo:
	- 

"""

extends Node
class_name CommandParser

