@tool
extends Node3D

@onready var batch := [$ifs1]
var compute := true
@export var gen_type := 0
@export var function_count := 5

@export var jump_ratio_min := 0.5
@export var jump_ratio_max := 0.5
@export var translate_min := Vector3.ZERO
@export var translate_max := Vector3.ZERO
@export var scaling_min := Vector3.ZERO
@export var scaling_max := Vector3.ZERO
@export var shear_min := Vector3.ZERO
@export var shear_max := Vector3.ZERO
@export var rotation_deg_min := Vector3.ZERO
@export var rotation_deg_max := Vector3.ZERO
@export var test := Transform3D.IDENTITY

var affine_arr := [Transform3D.IDENTITY, Transform3D.IDENTITY, Transform3D.IDENTITY,
				Transform3D.IDENTITY, Transform3D.IDENTITY, Transform3D.IDENTITY,
				Transform3D.IDENTITY, Transform3D.IDENTITY]
var affine_names := ["affine_0", "affine_1", "affine_2", "affine_3",
					"affine_4", "affine_5", "affine_6", "affine_7"]

# 3D affines in godot are column major (Transform3D) but editor shows them as row major
func generate_affines():
	if(gen_type == 0): # sierpinskie triangle
		function_count = 5
		for i in range(len(affine_arr)):
			var t = randf_range(jump_ratio_min, jump_ratio_max)
			affine_arr[i] = Transform3D(
				Vector3(t, 0.0, 0.0),
				Vector3(0.0, t, 0.0),
				Vector3(0.0, 0.0, t),
				Vector3(t*randf_range(translate_min.x, translate_max.x), t*randf_range(translate_min.y, translate_max.y),
				t*randf_range(translate_min.z, translate_max.z))
				)
	if(gen_type == 1): # freeform
		for i in range(len(affine_arr)):
			# translation and scaling
			var tx = randf_range(scaling_min.x, scaling_max.x)
			var ty = randf_range(scaling_min.y, scaling_max.y)
			var tz = randf_range(scaling_min.z, scaling_max.z)
			affine_arr[i] = Transform3D(
				Vector3(tx, 0.0, 0.0),
				Vector3(0.0, ty, 0.0),
				Vector3(0.0, 0.0, tz),
				Vector3(tx*randf_range(translate_min.x, translate_max.x), ty*randf_range(translate_min.y, translate_max.y),
				tz*randf_range(translate_min.z, translate_max.z))
				)
			# shears combined (mat3 formation precalculated)
			var shear_x = randf_range(shear_min.x, shear_max.x)
			var shear_y = randf_range(shear_min.y, shear_max.y)
			var shear_z = randf_range(shear_min.z, shear_max.z)
			# Sx
			affine_arr[i] *= Transform3D(
				Vector3(1.0, 0.0, 0.0),
				Vector3(shear_y, 1.0, 0.0),
				Vector3(shear_z, 0.0, 1.0),
				Vector3(0.0, 0.0, 0.0)
			)
			# Sy
			affine_arr[i] *= Transform3D(
				Vector3(1.0, shear_x, 0.0),
				Vector3(0.0, 1.0, 0.0),
				Vector3(0.0, shear_z, 1.0),
				Vector3(0.0, 0.0, 0.0)
			)
			# Sz
			affine_arr[i] *= Transform3D(
				Vector3(1.0, 0.0, shear_x),
				Vector3(0.0, 1.0, shear_y),
				Vector3(0.0, 0.0, 1.0),
				Vector3(0.0, 0.0, 0.0)
			)
			# rotation
			var a = randf_range(rotation_deg_min.y, rotation_deg_max.y)
			var b = randf_range(rotation_deg_min.x, rotation_deg_max.x)
			var c = randf_range(rotation_deg_min.z, rotation_deg_max.z)
			var cos_a = cos(a)
			var cos_b = cos(b)
			var cos_c = cos(c)
			var sin_a = sin(a)
			var sin_b = sin(b)
			var sin_c = sin(c)
			affine_arr[i] *= Transform3D(
				Vector3(cos_a*cos_b, sin_a*cos_b, -sin_b),
				Vector3(cos_a*sin_b*sin_c-(sin_a*cos_c),
				sin_a*sin_b*sin_c+(cos_a*cos_c),
				cos_b*sin_c),
				Vector3(cos_a*sin_b*cos_c+(sin_a*sin_c),
				sin_a*sin_b*cos_c-(cos_a*sin_c),
				cos_b*cos_c),
				Vector3(0.0, 0.0, 0.0)
			)

func apply_affines():
	for i in range(len(batch)):
		batch[i].process_material.set_shader_parameter("compute", compute)
		batch[i].process_material.set_shader_parameter("function_count", function_count)
		for j in range(len(affine_arr)):
			batch[i].process_material.set_shader_parameter(affine_names[j], affine_arr[j])

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in batch:
		i.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	InputMap.load_from_project_settings()
	if(Input.is_action_just_pressed("ui_end") && Engine.is_editor_hint()):
		generate_affines()
		apply_affines()
	elif(Input.is_action_just_pressed("ui_accept") && !Engine.is_editor_hint()):
		generate_affines()
		apply_affines()


func _on_timer_timeout():
	if($CanvasLayer/CheckButton.button_pressed):
		generate_affines()
		apply_affines()


func _on_h_slider_value_changed(value):
	$CanvasLayer/Label4.text = "Blue: " + str(value)
	for i in range(len(batch)):
		batch[i].process_material.set_shader_parameter("blue", value)


func _on_h_sliderred_value_changed(value):
	$CanvasLayer/Label2.text = "Red: " + str(value)
	for i in range(len(batch)):
		batch[i].process_material.set_shader_parameter("red", value)


func _on_h_slider_2_value_changed(value):
	$CanvasLayer/Label3.text = "Green: " + str(value)
	for i in range(len(batch)):
		batch[i].process_material.set_shader_parameter("green", value)
