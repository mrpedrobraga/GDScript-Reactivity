class_name Rx extends Object

## Static class which adds many methods to weave reactivity into your nodes.

const RX_META = &"RX_META"

## (Re)generates the children of a reactive object.
static func render(rx_parent: Node):
	assert(rx_parent.has_method("_render"), "Node '{name}' missing a `_render` method.".format({name = rx_parent.name}))
	
	_cleanup_content(rx_parent, rx_parent)
	var render_result = rx_parent._render()
	_commit_content(rx_parent, rx_parent, render_result)

## Parses and commits an object into children and bind it to a reactive parent.
static func _commit_content(rx_parent: Node, parent: Node, subject):
	if subject is Array:
		for i in subject:
			_commit_content(rx_parent, parent, i)
	
	if subject is Node:
		rx_parent.get_meta(RX_META).content_nodes.push_back(subject)
		parent.add_child(subject) if not subject.is_inside_tree() else subject.reparent(parent)
	
	if subject is ReactiveBound:
		_commit_content(rx_parent, parent, subject._get_default_node_repr(rx_parent))

## Cleans up the content of a reactive parent :-)
static func _cleanup_content(rx_parent: Node, parent: Node):
	# This here will use a better clean up!
	var meta = rx_parent.get_meta(RX_META)
	if meta:
		meta.content_nodes.map(func(c: Node):
			var p = c.get_parent()
			if p:
				p.remove_child(c)
			)
		meta.content_nodes.clear()

## Ensures a reactive parent has a set up meta dictionary.
static func _ensure_has_meta(rx_parent: Node):
	if not rx_parent.has_meta(RX_META):
		var meta = {
			rx_bounds = {},
			content_nodes = []
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

	properties.keys().map(func (key):
		match key:
			"on":
				for ksignal in properties[key].keys():
					node[ksignal].connect(properties[key][ksignal])
				return
			"children":
				for child in properties[key]:
					_commit_content(rx_parent, node, child)
				return
		
		_setup_content_node_property(meta, rx_parent, node, key, properties[key])
	)
	
	return node

static func _setup_content_node_property(meta, rx_parent: Node, node: Node, key, value):
	if value is ReactiveBound:
		value._bind_to_node_property(meta, rx_parent, node, key)
	else:
		node.set(key, value)

static func update(object: Node, key: StringName, new_value, old_value = null):
	if not object.has_meta(RX_META):
		push_warning(object, " isn't reactive (hasn't been setup as reactive.)")
		return

	var bounds: Dictionary = object.get_meta(RX_META).rx_bounds
	
	if not bounds.has(key):
		push_error(object, " has never created a bound with the key '", key, "'.")
		return
		
	var key_bounds: Array = (bounds[key])

	for bound in key_bounds:
		if bound is ReactiveBound and bound.keys.has(key):
			bound._update_scalar(key, new_value)

		if bound is ReactivityForwardingBound:
			if old_value and old_value.RX_update.is_connected(bound.f):
				old_value.RX_update.disconnect(bound.f)
			# bound is made through a resource!
			new_value.RX_update.connect(bound.f)
			new_value.RX_update.emit(bound.keys[0], new_value[bound.keys[0]])

# ------------------------------------- #

# Shorthands for creating reactive binds in properties.

## Creates a simple bound which sets the property
## directly when changed.
## Paired with scripts and setters on the receivers, this is already reactivity-complete.
static func react(key: StringName) -> ReactiveBound:
	return ReactiveBound.new(key)

## Reactive bound that formats the result given a string.
## It automatically binds itself to the keys inside the format string.
static func fmt(format_string: String) -> FormatReactiveBound:
	return FormatReactiveBound.new(format_string)

## Reactive bound that pipes the result to a callback.
## You _can_ not use the values if you want.
static func expr(keys: Array[StringName], callback: Callable) -> CallbackReactiveBound:
	return CallbackReactiveBound.new(keys, callback)

static func hbox(rx_parent: Node, _children: Array, properties: Dictionary = {}):
	properties.children = _children
	return Rx.node(rx_parent, HBoxContainer, properties)

static func vbox(rx_parent: Node, _children: Array, properties: Dictionary = {}):
	properties.children = _children
	return Rx.node(rx_parent, HBoxContainer, properties)

static func txt(rx_parent: Node, _text):
	return Rx.node(rx_parent, Label, { text = _text })

static func btn(rx_parent: Node, _text, _callback: Callable):
	return Rx.node(rx_parent, Button, { text = _text, on = {pressed = _callback} })
			
