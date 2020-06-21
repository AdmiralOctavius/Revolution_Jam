extends MeshInstance


onready var player = get_node("../Player")
onready var player2 = get_node("../Player2")
onready var dialogue_text = $Dialogue/Box/Text


export var dialogue_list = ["First Dialogue", "Second Dialogue", "LastDialogue"]
var current_dialogue = 0
var player_close = false
var talking = false


func _ready():
	dialogue_text.text = dialogue_list[current_dialogue]

func _input(event):
	if event.is_action_pressed("talk"):
		if player_close and !talking:
			talking = true
			$Dialogue.visible = true
			player.talking = true
			player.camera.current = false
			player2.talking = true
			player2.camera.current = false
			$Camera.current = true
		elif talking:
			next_dialogue()
	elif event.is_action_pressed("stopTalking") and player.talking:
		_stop_talking()
	elif event.is_action_pressed("stopTalking") and player2.talking:
		_stop_talking()
	

	
func _on_Talk_body_entered(body):
	player_close = true


func _on_Talk_body_exited(body):
	player_close = false

func next_dialogue():
	current_dialogue += 1
	if current_dialogue < dialogue_list.size():
		dialogue_text.text = dialogue_list[current_dialogue]
	else:
		_stop_talking()

func _stop_talking():
	talking = false
	$Dialogue.visible = false
	player.talking = false
	player.camera.current = true
	player2.talking = true
	player2.camera.current = false
	$Camera.current = false
