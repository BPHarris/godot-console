"""Class to store data and a status code.

Case of Error:
	status represents the error code from @GlobalScope.Error,
	error_message represents the error message, data remains empty
Case of Data:
	status is @GlobalScope.Error.OK, data contains the desired data,
	error_message remains empty

"""

extends Node
class_name ErrorOrData


var status : int
var data : Array
var error_message : String
