class_name FormatReactiveBound extends ReactiveBound

var format_string = ""
var values = {}

func _init(_keys: Array[StringName], _format_string: String):
	format_string = _format_string
	_keys.map(func(k): values[k] = null)

func _update_scalar(key: StringName, new_value):
	values[key] = new_value
	node[node_prop] = format_string.format(values, Rx.RX_FORMAT_KEY_PLACEHOLDER)