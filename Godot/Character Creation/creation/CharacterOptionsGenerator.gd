# This script generates UI Controls
# for modifying a character's blendshapes
extends TabContainer

@export var character_node_path:NodePath
@onready var character_node:Node3D
var characterBody:CharacterBody

func has_category(named:String) -> bool:
	return has_node(named)

func get_category(named:String, create:bool = true) -> VBoxContainer:
	if not has_category(named):
		var cat = VBoxContainer.new()
		cat.name = named
		add_child(cat)

	return get_node(named).get_node("ScrollContainer").get_node("VBoxContainer")

func _ready():
	if character_node_path:
		character_node = get_node(character_node_path)
		characterBody = character_node.get_node("character")

		for blendShape in characterBody.type.blendshapes:
			var category = get_category(blendShape.category)

			var control = create_control_for_blendshape_definition(blendShape)
			category.add_child(control)


func create_control_for_blendshape_definition(blendshape:BlendShapeDefinition) -> VBoxContainer:
	var c = VBoxContainer.new()
	c.set_meta("blendshape_definition", blendshape)

	var label = Label.new()
	label.text = blendshape.label
	c.add_child(label)

	var control = HSlider.new()
	control.max_value = blendshape.maximum
	control.min_value = blendshape.minimum
	control.value = blendshape.default
	control.step = 0.05

	control.value_changed.connect(_on_blendshape_control_value_changed.bind(blendshape))

	c.add_child(control)

	return c

func _on_blendshape_control_value_changed(value, blendShape):
	characterBody.apply_blendshape_to_body(blendShape.blendshape, value, true)
