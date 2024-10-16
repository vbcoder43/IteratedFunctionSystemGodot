@tool
extends Node2D

@onready var batch := [$ifs1]
var compute := true
@export var gen_type := 0
@export var function_count := 3

@export var jump_ratio_min := 0.5
@export var jump_ratio_max := 0.5
@export var translate_min := Vector2.ZERO
@export var translate_max := Vector2.ZERO
@export var scaling_min := Vector2.ZERO
@export var scaling_max := Vector2.ZERO
@export var shear_min := Vector2.ZERO
@export var shear_max := Vector2.ZERO
@export var rotation_deg_min := 0.0
@export var rotation_deg_max := 0.0

var affine_arr := [Basis.IDENTITY, Basis.IDENTITY, Basis.IDENTITY,
				Basis.IDENTITY, Basis.IDENTITY, Basis.IDENTITY,
				Basis.IDENTITY, Basis.IDENTITY]
var affine_names := ["affine_0", "affine_1", "affine_2", "affine_3",
					"affine_4", "affine_5", "affine_6", "affine_7"]


func generate_affines():
	if(gen_type == 0): # sierpinskie triangle
		function_count = 3
		for i in range(len(affine_arr)):
			affine_arr[i] = Basis(
				Vector3(randf_range(jump_ratio_min, jump_ratio_max), 0.0, 0.0),
				Vector3(0.0, randf_range(jump_ratio_min, jump_ratio_max), 0.0),
				Vector3(randf_range(translate_min.x, translate_max.x), randf_range(translate_min.y, translate_max.y), 1.0)
				)
	if(gen_type == 1): # freeform
		for i in range(len(affine_arr)):
			# translation and scaling
			affine_arr[i] = Basis(
				Vector3(randf_range(scaling_min.x, scaling_max.x), 0.0, 0.0),
				Vector3(0.0, randf_range(scaling_min.y, scaling_max.y), 0.0),
				Vector3(randf_range(translate_min.x, translate_max.x), randf_range(translate_min.y, translate_max.y), 1.0)
				)
			# shears combined (mat3 formation precalculated)
			var shear_h = randf_range(shear_min.y, shear_max.y)
			var shear_v = randf_range(shear_min.x, shear_max.x)
			affine_arr[i] *= Basis(
				Vector3(1.0, shear_h, 0.0),
				Vector3(shear_v, shear_h*shear_v+1, 0.0),
				Vector3(0.0, 0.0, 1.0)
			)
			# rotation
			var angle_sin = sin(randf_range(deg_to_rad(rotation_deg_min),deg_to_rad(rotation_deg_max)))
			var angle_cos = cos(randf_range(deg_to_rad(rotation_deg_min),deg_to_rad(rotation_deg_max)))
			affine_arr[i] *= Basis(
				Vector3(angle_cos, angle_sin, 0.0),
				Vector3(-angle_sin, angle_cos, 0.0),
				Vector3(0.0, 0.0, 1.0)
			)

func apply_affines():
	for i in range(len(batch)):
		batch[i].process_material.set_shader_parameter("compute", compute)
		batch[i].process_material.set_shader_parameter("function_count", function_count)
		for j in range(len(affine_arr)):
			batch[i].process_material.set_shader_parameter(affine_names[j], affine_arr[j])

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	InputMap.load_from_project_settings()
	if(Input.is_action_just_pressed("ui_end")):
		generate_affines()
		apply_affines()
