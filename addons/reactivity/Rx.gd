class_name Rx extends Object

## Static class which adds many methods to weave reactivity into your nodes.

const RX_META = &"RX_META"
const RX_FORMAT_KEY_PLACEHOLDER = "&{_}"
const RX_FORMAT_KEY_PLACEHOLDER_REGEX = "&\\{([a-zA-Z_][a-zA-Z_0-9]*)\\}"

## (Re)generates the children of a reactive object.
static func render(rx_parent: Node):
	if rx_parent.has_meta(RX_META):
		rx_parent.remove_meta(RX_META)
	
	assert(rx_parent.has_method("_render"), "Node '{name}' missing a `_render` method.".format({name = rx_parent.name}))
	
	var render_result = rx_parent._render()

	_cleanup_content(rx_parent, rx_parent)
	_commit_content(rx_parent, rx_parent, render_result)

## Parses and commits an object into children and bind it to a reactive parent.
static func _commit_content(rx_parent: Node, parent: Node, subject):
	if subject is Array:
		for i in subject:
			_commit_content(rx_parent, parent, i)
	
	if subject is Node:
		parent.add_child(subject)

## Cleans up the content of a reactive parent :-)
static func _cleanup_content(rx_parent: Node, parent: Node):
	# This here will use a better clean up!
	rx_parent.get_children().map(func(c): c.queue_free())

## Ensures a reactive parent has a set up meta dictionary.
static func _ensure_has_meta(rx_parent: Node):
	if not rx_parent.has_meta(RX_META):
		var meta = {
			rx_bounds = {}
		}
		rx_parent.set_meta(RX_META, meta)
		return meta
	return rx_parent.get_meta(RX_META)

static func _make(template) -> Node:
	if template is PackedScene:
		return template.instantiate()
	return template.new()

## Creates and returns a reactive node, as well as binds it to a reactive parent.
static func node(rx_parent: Node, template, properties: Dictionary):
	var meta = _ensure_has_meta(rx_parent)
	var node = _make(template)

	for key in properties.keys():
		match key:
			"on":
				for sig in properties[key].keys():
					(node[sig] as Signal).connect(properties[key][sig])
				continue
		
		var v = properties[key]
		if v is FormatReactiveBound:
			v.node = node
			v.node_prop = key
			for k in v.values.keys():
				if not meta.soft_bounds.has(k):
					meta.soft_bounds[k] = []
				meta.soft_bounds[k].push_back(v)
				v._update_scalar(key, v.values[k])
		elif v is ReactiveBound:
			v.node = node
			v.node_prop = key
			if not meta.soft_bounds.has(v.keys[0]):
				meta.soft_bounds[v.keys[0]] = []
			meta.soft_bounds[v.keys[0]].push_back(v)
			var vv = rx_parent.get(key)
			if vv:
				v._update_scalar(key, rx_parent.get(key))
			# Create resource bounds using strings of the keys to update!
			if v.resource_prop_name:
				if not meta.soft_bounds.has(v.resource_prop_name):
					meta.soft_bounds[v.resource_prop_name] = []
				meta.soft_bounds[v.resource_prop_name].push_back(
					ReactivityForwardingBound.new(rx_parent, [v.keys[0]])
				)
		else:
			node.set(key, v)
	return node

static func update(object: Node, key: StringName, new_value, old_value = null):
	if not object.has_meta(RX_META):
		push_warning(object, " isn't reactive (hasn't been setup as reactive.)")
		return
	var bounds: Dictionary = object.get_meta(RX_META).soft_bounds
	if not bounds.has(key):
		push_error(object, " has never created a bound with the key '", key, "'.")
		return
	var key_bounds: Array = (bounds[key])
	for bound in key_bounds:
		if bound is ReactiveBound:
			# bound is a scalar!
			bound._update_scalar(key, new_value)
		if bound is ReactivityForwardingBound:
			if old_value and old_value.RX_update.is_connected(bound.f):
				old_value.RX_update.disconnect(bound.f)
			# bound is made through a resource!
			new_value.RX_update.connect(bound.f)
			new_value.RX_update.emit(bound.keys[0], new_value[bound.keys[0]])

static func react(key: StringName) -> ReactiveBound:
	return ReactiveBound.new(key)

static func fmt(format_string: String) -> FormatReactiveBound:
	var r = RegEx.create_from_string(RX_FORMAT_KEY_PLACEHOLDER_REGEX)
	var matches = r.search_all(format_string)
	var keys: Array[StringName]
	keys.assign(
		matches.map(
			func(m: RegExMatch) -> String: return StringName(m.get_string(1)))
		)
	return FormatReactiveBound.new(keys, format_string)