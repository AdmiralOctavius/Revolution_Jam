extends KinematicBody

const SPEED = 5
const JUMPSPEED = 11
var GRAVITY = 0.3
const MAX_FALL_SPEED = 50
 
var HSENS = 0.6
var VSENS = 0.6
 
onready var cam = $Camera

var y_velo = 0
var talking = false


func _ready():
	pass
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


 
func _input(event):
	if event is InputEventMouseMotion:
		if GRAVITY > 0:
			cam.rotation_degrees.x -= event.relative.y * VSENS
			cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, -90, 90)
			rotation_degrees.y -= event.relative.x * HSENS
		else:
			cam.rotation_degrees.x -= event.relative.y * VSENS
			cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, 90, 270)
			rotation_degrees.y += event.relative.x * HSENS
func _physics_process(_delta):
	if !talking:
		move()	

func move():
	var movement = Vector3()
	if Input.is_action_pressed("movement_forward"):
		movement.z -= 1
	if Input.is_action_pressed("movement_backward"):
		movement.z += 1
	if Input.is_action_pressed("movement_right"):
		movement.x += 1
	if Input.is_action_pressed("movement_left"):
		movement.x -= 1
	movement = movement.normalized()
	movement = movement.rotated(Vector3(0, 1, 0), rotation.y)
	movement *= SPEED
	movement.y = y_velo
# warning-ignore:return_value_discarded
	move_and_slide(movement, Vector3(0, 1, 0))

	var grounded = is_on_floor()
	y_velo -= GRAVITY
# warning-ignore:unused_variable
	var jumped = false

	
	if GRAVITY > 0:
		if is_on_floor() and Input.is_action_just_pressed("jump"):
			jumped = true
			y_velo = JUMPSPEED
		if y_velo < -MAX_FALL_SPEED:
			y_velo = -MAX_FALL_SPEED
