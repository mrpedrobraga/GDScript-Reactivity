extends VBoxContainer

@export var res: FunkyResource

func _ready():
	Rx.render(self)

var todos = Rx.each(self, VBoxContainer, [],
	func(i, v):
		return Rx.hbox(self,
			[
				Rx.btn(self, "X", func(): todos.remove_at(i)),
				Rx.txt(self, v)
			]
		))

func add_todo():
	todos.push_back(todo_content.text)
	todo_content.clear()

var todo_content = Rx.node(self,
	LineEdit, {
		size_flags_horizontal = SIZE_EXPAND_FILL,
		on = {
			text_submitted = add_todo.unbind(1)
		}
	})

var btn_add_todo = Rx.btn(self, "Submit", add_todo)
	
func _render_todo():
	return [
		Rx.hbox(self, [todo_content, btn_add_todo]),
		todos
	]

@export var counter: int = 0:
	set(v):
		Rx.update(self, &"counter", v, counter)
		counter = v

func _render_counter():
	return [
		Rx.node(self, Button, {
			text = Rx.fmt("Counter: &{counter}"),
			on = {
				pressed = (func():
					counter += 1
					)
			}
		})
	]

func _render():
	return range(0, 10).map((func(_x): return _render_counter()))