# This node handles the applying of all of the options other than blendshapes
extends Control

@export var character_node_path:NodePath
@onready var character_node:Node3D
var characterBody:CharacterBody


func _ready():
	if character_node_path:
		character_node = get_node(character_node_path)
		characterBody = character_node.get_node("character")


func _on_eye_color_picker_color_changed(color):
	characterBody.set_eye_color(color)


func _on_skin_color_picker_color_changed(color):
	characterBody.set_skin_color(color)


func _on_hair_color_picker_color_changed(color):
	characterBody.set_hair_color(color)
