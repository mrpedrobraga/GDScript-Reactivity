extends PanelContainer

@export var default_images: Array[Texture]

var gallery = ArrayContainer.new(self, FlowContainer, [], ImageView)

func _ready():
	for i in default_images:
		gallery.push_back(i)
	
	Rx.render(self)

func _render():
	return gallery

# ImageView component!
# A Component can be either a scene or a function!
func ImageView(props):
	return [
		Rx.node(self,
			TextureRect,
			{ texture = (props.img if props.has("img") else props.value) }
		)
	]
