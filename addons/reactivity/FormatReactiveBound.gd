class_name FormatReactiveBound extends ReactiveBound

const RX_FORMAT_KEY_PLACEHOLDER = "&{_}"
const RX_FORMAT_KEY_PLACEHOLDER_REGEX = "&{([a-zA-Z_][a-zA-Z_0-9]*)}"

var format_string = ""
var values = {}

func _init(_format_string: String):
	var r = RegEx.create_from_string(RX_FORMAT_KEY_PLACEHOLDER_REGEX)
	var matches = r.search_all(_format_string)
	keys.assign(
		matches.map(
			func(m: RegExMatch) -> String: return StringName(m.get_string(1)))
		)

	format_string = _format_string
	keys.map(func(k): values[k] = null)

func _update_scalar(key: StringName, new_value):
	values[key] = new_value
	node[prop_name] = format_string.format(values, RX_FORMAT_KEY_PLACEHOLDER)

func _get_default_node_repr(rx_parent: Node):
	return Rx.node(rx_parent, Label, { text = self })

func _bind_to_node_property(meta, rx_parent: Node, _node: Node, _key):
	node = _node
	prop_name = _key

	for k in values.keys():
		if not meta.rx_bounds.has(k):
			meta.rx_bounds[k] = []
		
		meta.rx_bounds[k].push_back(self)
		_update_scalar(_key, values[k])