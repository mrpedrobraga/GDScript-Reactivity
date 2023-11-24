extends VBoxContainer

func _ready():
	Rx.render(self)

func _render():
	var btn = Rx.node(self,
		Button, {
			text = "Hello world!",
			on = {
				pressed = func(): OS.alert("Hello there!", "Message!")
			}
		}
	)
	return [btn]