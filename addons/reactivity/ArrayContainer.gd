class_name ArrayContainer extends Container

var _rx_parent: Node
var _array: Array
var _container: Node
var _content_callback: Callable

func _init(rx_parent: Node, container_template, array: Array, content_callback: Callable):
	Rx._ensure_has_meta(rx_parent)

	_container = Rx._make(container_template)
	_array = array
	_content_callback = content_callback
	_rx_parent = rx_parent
	populate()

	add_child(_container)

func populate():
	var i = 0
	for v in _array:
		_container.add_child(_content_callback.call({ key = i, value = v }))
		i += 1

func _notification(what):
	match what:
		NOTIFICATION_SORT_CHILDREN:
			fit_child_in_rect(_container, get_rect())

func push_back(value):
	print(_rx_parent)
	_array.push_back(value)
	var c = _content_callback.call({ key = _array.size() - 1, value = value })
	Rx._commit_content(null, _container, c)

func remove_at(index: int):
	_array.remove_at(index)
	_container.get_children().map(func(c): c.queue_free())
	populate()

func get_nodes():
	return _container.get_children()
