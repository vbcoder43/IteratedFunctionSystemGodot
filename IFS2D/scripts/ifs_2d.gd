@tool
extends Node2D

@onready var ifs = $ifs1
@export var compute := true
@export var gen_type := 0
@export var function_count := 3
var acc_time := 0.0
@export var decay_rate := 4.0
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

# 2D affines in godot are column major (Basis type)
func generate_affines():
	if(gen_type == 0): # sierpinskie triangle
		function_count = 3
		for i in range(len(affine_arr)):
			var t = randf_range(jump_ratio_min, jump_ratio_max)
			affine_arr[i] = Basis(
				Vector3(t, 0.0, 0.0),
				Vector3(0.0, t, 0.0),
				Vector3(t*randf_range(translate_min.x, translate_max.x), t*randf_range(translate_min.y, translate_max.y), 1.0)
				)
	if(gen_type == 1): # freeform
		for i in range(len(affine_arr)):
			# translation and scaling
			var tx = randf_range(scaling_min.x, scaling_max.x)
			var ty = randf_range(scaling_min.y, scaling_max.y)
			affine_arr[i] = Basis(
				Vector3(tx, 0.0, 0.0),
				Vector3(0.0, ty, 0.0),
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
			var theta = randf_range(deg_to_rad(rotation_deg_min),deg_to_rad(rotation_deg_max))
			var angle_sin = sin(theta)
			var angle_cos = cos(theta)
			affine_arr[i] *= Basis(
				Vector3(angle_cos, angle_sin, 0.0),
				Vector3(-angle_sin, angle_cos, 0.0),
				Vector3(0.0, 0.0, 1.0)
			)

func apply_affines():
	acc_time = 0.0
	ifs.process_material.set_shader_parameter("compute", compute)
	ifs.process_material.set_shader_parameter("function_count", function_count)
	ifs.process_material.set_shader_parameter("decay_rate", decay_rate)
	for j in range(len(affine_arr)):
		ifs.process_material.set_shader_parameter(affine_names[j], affine_arr[j])

# Called when the node enters the scene tree for the first time.
func _ready():
	ifs.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	ifs.process_material.set_shader_parameter("compute", compute)
	if(compute):
		acc_time = acc_time + delta
		ifs.process_material.set_shader_parameter("acc_time", acc_time)
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
	ifs.process_material.set_shader_parameter("blue", value)


func _on_h_sliderred_value_changed(value):
	$CanvasLayer/Label2.text = "Red: " + str(value)
	ifs.process_material.set_shader_parameter("red", value)


func _on_h_slider_2_value_changed(value):
	$CanvasLayer/Label3.text = "Green: " + str(value)
	ifs.process_material.set_shader_parameter("green", value)


func _on_h_slider_4_value_changed(value):
	$CanvasLayer/Label5.text = "Decay Rate: " + str(value)
	decay_rate = value
