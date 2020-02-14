# godot-console <!-- omit in toc -->
A simple Source-enigine inspired game console for Godot.

- [Adding to a Godot Project](#adding-to-a-godot-project)
- [Usage](#usage)
- [Adding Custom Commands](#adding-custom-commands)
- [Command Argument Types](#command-argument-types)
- [Default Commands](#default-commands)

# Adding to a Godot Project
1. Copy the `./Console` directory into your Godot project.
2. Add an instance of `Console.tscn` to your scene's root node.
3. Ensure that your Godot project has keys assigned to:
    1. 'dev_toggle_console' -- to toggle the console open/closed
    2. 'ui_cancel' -- to close the console   (NB: assigned by default)
    3. 'ui_up' -- to navigate up in command history  (NB: assigned by default)
    4. 'ui_down' -- to navigate down in command history  (NB: assigned by default)
    5. 'ui_enter' -- to enter a command  (NB: assigned by default)

# Usage
To use the console, simply press the 'dev_toggle_console' key to open the console,
type a command, and press 'ui_enter'.

# Adding Custom Commands
Simply call `$console.add_command(`*args*`)` where `$console` is a reference to the
console node. The function implementing the command must return a CommandResponse instance.

Custom command arguments:
- `command_name` : the name the command will be called with
- `parent_node` : a refence the node that stores the method that implements the command (usually `self`)
- `function_name` : the name of the method/function that implements the command (optional, default = `command_name`)
- `command_arguments` : the names and types of the command/functions arguments (optional, default = empty)
- `description` : a description of the commands function (optional)
- `help` : a help string for the command, usually a usage style string (optional, default = automatically derived)

If a result is returned, it will be printed to the console.

Typing info omitted in examples for better syntax highlighting on GitHub.

Example:
```GDScript
func _read():
    console.add_command(
        'my_command',
        self,
        '_my_command',
        [['x', TYPE_INT], ['s', TYPE_STRING]],
        'this is my custom command',
        'usage:\n\tmy_command <int: x> <string: s>'
    )

func _my_command(x, s):
    # Your command logic here
    ...

    # On error
    if error:
        return CommandResponse.new(CommandResponse.ResponseType.ERROR, 'description of error')
    
    return CommandResponse.new(CommandResponse.ResponseType.RESULT, 'result/response as string')
```

Worked example of an echo command:
```GDScript
func _ready():
    console.add_command(
        "echo",
        self,
        '_echo_to_console',
        ['output', TYPE_STRING],
        'echo to console',
        'usage:\n\techo <string>'
    )

func _echo_to_console(output = ''):
    return CommandResponse.new(CommandResponse.ResponseType.RESULT, output)
```

# Command Argument Types
See `./Console/Source/types.gd`.

Argument Types:
- TYPE_INT
- TYPE_STRING
- TYPE_FLOAT
- TYPE_NODE


# Default Commands
- `clear` : clears the console output
- `help` : prints `'{description}\n{help}'` to the console output
- `exit` : closes the console
- `quit` : quits the game
- `echo` : takes a string and prints it to the console

Any of these can be disabled via exported console variables.
