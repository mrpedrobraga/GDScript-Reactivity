class_name ReactiveBound

var keys: Array[String]
var node: Node
var prop_name: StringName

## If this is true, the reactivity update won't be triggered
## from inside the reactive container, but from the resource
## at this property.
var resource_prop_name: StringName

func _init(_key: String):
	self.keys = [_key]

## Updates the internal scalar however seen fit!
## This method can be overriden!
func _update_scalar(key: StringName, new_value):
	node[prop_name] = new_value

## The key that updates this bound will be emitted
## from a resource, and not the container.
func from_resource(prop_name: StringName):
	resource_prop_name = prop_name
	return self

func _bind_to_node_property(meta, rx_parent: Node, _node: Node, prop_name):
	node = _node
	prop_name = prop_name

	if not meta.rx_bounds.has(keys[0]):
		meta.rx_bounds[keys[0]] = []
	meta.rx_bounds[keys[0]].push_back(self)
	
	var vv = rx_parent.get(prop_name)
	if vv:
		_update_scalar(prop_name, rx_parent.get(prop_name))
	
	# Create resource bounds using strings of the keys to update!
	if resource_prop_name:
		if not meta.rx_bounds.has(resource_prop_name):
			meta.rx_bounds[resource_prop_name] = []
		meta.rx_bounds[resource_prop_name].push_back(
			ReactivityForwardingBound.new(rx_parent, [keys[0]])
		)

func _get_default_node_repr(_rx_parent: Node):
	return null

func _to_string():
	if keys.size() == 0:
		return "[Uninitialized REACT]"
	return "[REACT to {key} set target::{prop_name}]".format({"key": keys[0], "prop_name": prop_name})

