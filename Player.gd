extends KinematicBody

#og amt: -24.8
#juicy amt: -50
const GRAVITY = -50
var vel = Vector3()
#og amt: 20
#juicy amt: 
const MAX_SPEED = 25
#og amt: 18
#juicy amt: 30
const JUMP_SPEED = 30
#og amt: 4.5
#juicy amt: 7.5
const ACCEL = 7.5

var dir = Vector3()

#og amt: 16
#juicy amt: 5
const DEACCEL = 5
const MAX_SLOPE_ANGLE = 40

var camera
var rotation_helper

var MOUSE_SENSITIVITY = 0.05

const MAX_SPRINT_SPEED = 35
const SPRINT_ACCEL = 18
var is_sprinting = false

var flashlight

#---
#End tutorial variables
#Start self variables
#---

#bool to denote whether active as witch or not
var activeWitch = false

var climbingArea
var onLadder = false
var ladderUp
var ladderSpeed = 14

var punchArea

func _ready():
	camera = $Rotation_Helper/Camera
	rotation_helper = $Rotation_Helper
	climbingArea = $Rotation_Helper/ClimbingCheck/Aim_Area/Area
	punchArea = $Rotation_Helper/PunchCheck/Aim_Area/Area
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	flashlight = $Rotation_Helper/Flashlight
	
func _physics_process(delta):
	process_input(delta)
	process_movement(delta)
	
func process_input(delta):
	
	#---
	#Walking
	dir = Vector3()
	var cam_xform = camera.get_global_transform()
	
	var input_movement_vector = Vector2()
	
	if Input.is_action_pressed("movement_forward"):
		if onLadder:
			ladderUp = true
		else:
			input_movement_vector.y += 1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x += 1
	
	input_movement_vector = input_movement_vector.normalized()
	
	#basis vectors are already normalized
	dir += -cam_xform.basis.z * input_movement_vector.y
	dir += cam_xform.basis.x * input_movement_vector.x
	#---
	
	#---
	#Jumping
	if is_on_floor():
		if Input.is_action_just_pressed("movement_jump"):
			vel.y = JUMP_SPEED
	#---
	
	#---
	#Capturing/Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#---
	
	#---
	#Sprinting
	if Input.is_action_pressed("movement_sprint"):
		is_sprinting=true
	else:
		is_sprinting = false
	#---
	
	#---
	#Turning the flashlight on/off
	if Input.is_action_just_pressed("flashlight"):
		if flashlight.is_visible_in_tree():
			flashlight.hide()
		else:
			flashlight.show()
	#---
	
	#---
	#Punching
	if Input.is_action_just_pressed("fire"):
		var areas = punchArea.get_overlapping_bodies()
		if !areas.empty():
			if areas[0].name == "PunchWall":
				print("Got punch wall")
				areas[0].queue_free()
			
func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()
	
	if ladderUp:
		vel.y += delta * ladderSpeed
	else:
		vel.y += delta * GRAVITY
	
	var hvel = vel
	hvel.y = 0
	
	var target = dir
	#target *= MAX_SPEED
	if is_sprinting:
		target *= MAX_SPRINT_SPEED
	else:
		target *= MAX_SPEED
	
	var accel
	if dir.dot(hvel) > 0:
		#accel = ACCEL
		if is_sprinting:
			accel = SPRINT_ACCEL
		else:
			accel = ACCEL
	else:
		accel = DEACCEL
		
	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel, Vector3(0,1,0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))
	
func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))
		
		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot
		#print(rotation_helper.rotation_degrees.y)




func _on_Area_body_entered(body):
	if body.name == "Ladder":
		print("Found a ladder")
		onLadder = true


func _on_Area_body_exited(body):
	if body.name == "Ladder":
		print("Exiting a ladder")
		onLadder = false
		ladderUp = false
