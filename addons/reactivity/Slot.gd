class_name Slot extends Resource

var content:
	set(v):
		content = v
		emit_changed()

func _init(_content):
	content = _content

func bind(rx_target: Node, key: StringName):
	changed.connect(func(): Rx.update(rx_target, key, content))
