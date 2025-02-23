extends Node3D
class_name CameraPivot


const MOUSE_SENSITIVITY = 0.002
#rotate the springarm for pitch
@onready var springarm : Node3D = $SpringArm3D
@onready var _camera: Camera3D = $SpringArm3D/Camera3D

var _target: Node3D


func activate() -> void:
	_camera.current = true


func set_target(target: Node3D) -> void:
	_target = target
	
	
func _process(delta: float) -> void:
	if _target:
		global_position = _target.global_position

	#
#func _input(event: InputEvent) -> void:
	#if event is InputEventMouseMotion:
		#rotate_y(event.relative.x * -MOUSE_SENSITIVITY)
		#springarm.rotation.x = clamp(springarm.rotation.x - event.relative.y * MOUSE_SENSITIVITY,-0.6,0.6)
