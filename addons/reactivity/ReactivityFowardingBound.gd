class_name ReactivityForwardingBound

var keys: Array[String]
var f: Callable

func _init(object:Node, _keys: Array[String]):
	keys = _keys
	f = func(key, new_value): (
		Rx.update(object, key, new_value)
	)
