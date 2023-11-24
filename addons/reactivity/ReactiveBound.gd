class_name ReactiveBound

var keys: Array[String]
var node: Node
var node_prop: StringName

## If this is true, the reactivity update won't be triggered
## from inside the reactive container, but from the resource
## at this property.
var resource_prop_name: StringName

func _init(_key: String):
	self.keys = [_key]

## Updates the internal scalar however seen fit!
## This method can be overriden!
func _update_scalar(key: StringName, new_value):
	node[node_prop] = new_value

## The key that updates this bound will be emitted
## from a resource, and not the container.
func from_resource(prop_name: StringName):
	resource_prop_name = prop_name
	return self

func _to_string():
	if keys.size() == 0:
		return "[Uninitialized REACT]"
	return "[REACT to {key} set target::{node_prop}]".format({"key": keys[0], "node_prop": node_prop})

