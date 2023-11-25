class_name CallbackReactiveBound extends ReactiveBound

var callback: Callable
var values = {}

func _init(_keys: Array[StringName], _callback: Callable):
	callback = _callback
	keys.assign(_keys)
	keys.map(func(k): values[k] = null)

func _update_scalar(key: StringName, new_value):
	values[key] = new_value
	node[prop_name] = callback.call(values)

func _bind_to_node_property(meta, rx_parent: Node, _node: Node, _key):
	node = _node
	prop_name = _key

	for k in values.keys():
		if not meta.rx_bounds.has(k):
			meta.rx_bounds[k] = []
		
		meta.rx_bounds[k].push_back(self)
	
	node[prop_name] = callback.call(values)
