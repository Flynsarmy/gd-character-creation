class_name BlendShapeDefinition extends Resource

@export var blendshape:String = "blend_shape" # the blendshape in the mesh
@export var category:String = "Body"
@export var label:String
@export var minimum:float = -1.0 # minimum value
@export var default:float = 0.0 # default value
@export var maximum:float = 1.0 # maximum value
@export var propogates:bool = true # whether this blendshape should propogate to sub meshes and clothing
